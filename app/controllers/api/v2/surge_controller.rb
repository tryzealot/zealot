class Api::V2::SurgeController < ActionController::API
  before_action :simple_auth

  rescue_from ActionCable::Connection::Authorization::UnauthorizedError, with: :render_unauthorized_user_key

  def show
    servers = {}

    # return render plain: ss

    name = icon = address = port = method = password = nil
    ss_script.split("\n").each do |line|
      next unless line.include?('rt_ss_')
      line = line.chomp

      type, value = match_quote(line)
      case type
      when 'name'
        data = server_name value.gsub('"', '')
        name = data[:name]
        icon = data[:icon]
        is_same = false
      when 'port'
        port = value
        is_same = false
      when 'server'
        address = value
        is_same = false
      when 'password'
        password = value.gsub('"', '')
        is_same = false
      when 'method'
        method = value
        is_same = true
      end

      if is_same
        servers[name] ||= []
        servers[name] << {
          icon: icon,
          address: address,
          port: port,
          method: method,
          password: password
        }
      end

    end

    config = [
      surge_header,
      surge_body(servers),
      surge_footbar
    ]

    render plain: config.join("\n")
  end

  private

  def simple_auth
    if params[:key] != 'mX7YsJx5a0ZASBfy'
      raise ActionCable::Connection::Authorization::UnauthorizedError, 'No auth'
    end

    @key = params[:key]
  end

  def render_unauthorized_user_key(exception)
    render json: {
      error: exception.message
    }, status: :unauthorized
  end

  def ss_script
    return @script if @script

    r = HTTP.get "https://www.ppssr.tk/link/#{@key}?is_ss=1"
    @script = r.body.to_s
  end

  def server_name(name)
    names = {
      '俄罗斯' => {
        name: 'RU',
        icon: '🇷🇺'
      },
      '台湾' => {
        name: 'TW',
        icon: '🇷🇪'
      },
      '香港' => {
        name: 'HK',
        icon: '🇭🇰'
      },
      '新加坡' => {
        name: 'SG',
        icon: '🇸🇬'
      },
      '日本' => {
        name: 'JP',
        icon: '🇯🇵'
      },
      '美国' => {
        name: 'US',
        icon: '🇺🇸'
      },
      '澳大利亚' => {
        name: 'AU',
        icon: '🇦🇺'
      },
    }

    names.each do |cn, data|
      return data if name.include?(cn)
    end
  end

  def surge_body(servers)
    body = []
    body << '[Proxy]' << '🚀 Direct = direct'

    countries = {}
    servers.each do |country, items|
      country_name = "#{items[0][:icon]} #{country}"
      countries[country_name] = []
      items.each_with_index do |item, i|
        no = i + 1
        name = "#{country}#{no}"
        str = "#{name} = custom,#{item[:address]},#{item[:port]},#{item[:method]},#{item[:password]},https://www.ppssr.tk/downloads/SSEncrypt.module"
        body << str

        countries[country_name] << name
      end
    end

    countries_keys = countries.values.join(',')
    body << '' << '[Proxy Group]'
    body << "🍃 Proxy = select,🏃 Auto,🚀 Direct,✈️ Air"
    body << '🍂 Domestic = select,🚀 Direct,🍃 Proxy'
    body << "🍎 Only = select,🚀 Direct,✈️ Air"
    body << "🏃 Auto = url-test,#{countries_keys},url = http://www.gstatic.com/generate_204,interval = 1200"
    body << "✈️ Air = select,#{countries_keys}"
    body << ''
    body
  end

  def match_quote(line)
    if match = line.match(/rt_ss_(.+)_(.+)=(.+)/)
      return [match[1], match[3]]
    end
  end

  def surge_header
<<-EOF
#!MANAGED-CONFIG #{api_v2_surge_config_url(@key)} interval=3600 strict=true
# Updated on #{Time.now}

[General]
// Auto
loglevel = notify
dns-server = system
skip-proxy = 127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10,17.0.0.0/8,localhost,*.local,e.crashlytics.com,captive.apple.com,::ffff:0:0:0:0/1,::ffff:128:0:0:0/1,*.2b6.me,*.dev,*.exp.direct,exp.host

// iOS
external-controller-access = icyleaf@0.0.0.0:6170

// macOS
interface = 0.0.0.0
socks-interface = 0.0.0.0
port = 8888
socks-port = 8889

// Off：On | "true" or "false"
allow-wifi-access = true
collapse-policy-group-items = true
enhanced-mode-by-rule = true
exclude-simple-hostnames = true
hide-crashlytics-request = true
ipv6 = true

[Replica]
hide-apple-request = true
hide-crashlytics-request = true
use-keyword-filter = false
EOF
  end

  def surge_footbar
<<-EOF
[Rule]
# Custom

DOMAIN,baby.ews.im,🍂 Domestic
DOMAIN-SUFFIX,2b6.me,🍂 Domestic

# Apple

URL-REGEX,apple.com/cn,🍎 Only

PROCESS-NAME,trustd,🍎 Only
PROCESS-NAME,storedownloadd,🍎 Only

USER-AGENT,*com.apple.mobileme.fmip1,🍎 Only
USER-AGENT,*WeatherFoundation*,🍎 Only
USER-AGENT,%E5%9C%B0%E5%9B%BE*,🍎 Only
USER-AGENT,%E8%AE%BE%E7%BD%AE*,🍎 Only
USER-AGENT,AppStore*,🍎 Only
USER-AGENT,com.apple.appstored*,🍎 Only
USER-AGENT,com.apple.Mobile*,🍎 Only
USER-AGENT,com.apple.geod*,🍎 Only
USER-AGENT,com.apple.Maps*,🍎 Only
USER-AGENT,com.apple.trustd/*,🍎 Only
USER-AGENT,FindMyFriends*,🍎 Only
USER-AGENT,FindMyiPhone*,🍎 Only
USER-AGENT,FMDClient*,🍎 Only
USER-AGENT,FMFD*,🍎 Only
USER-AGENT,fmflocatord*,🍎 Only
USER-AGENT,geod*,🍎 Only
USER-AGENT,i?unes*,🍎 Only
USER-AGENT,locationd*,🍎 Only
USER-AGENT,MacAppStore*,🍎 Only
USER-AGENT,Maps*,🍎 Only
USER-AGENT,MobileAsset*,🍎 Only
USER-AGENT,Watch*,🍎 Only
USER-AGENT,$%7BPRODUCT*,🍎 Only
USER-AGENT,Music*,🍎 Only
USER-AGENT,?arsecd*,🍎 Only
USER-AGENT,securityd*,🍎 Only
USER-AGENT,server-bag*,🍎 Only
USER-AGENT,Settings*,🍎 Only
USER-AGENT,Software%20Update*,🍎 Only
USER-AGENT,SyncedDefaults*,🍎 Only
USER-AGENT,passd*,🍎 Only
USER-AGENT,swcd*,🍎 Only
USER-AGENT,trustd*,🍎 Only

DOMAIN,aod.itunes.apple.com,🍎 Only
DOMAIN,api.smoot.apple.cn,🍎 Only
DOMAIN,api.smoot.apple.com,🍎 Only
DOMAIN,cn-smp-paymentservices.apple.com,🍂 Domestic
DOMAIN,support.apple.com,🍎 Only
DOMAIN,smp-device-content.apple.com,🍎 Only
DOMAIN,osxapps.itunes.apple.com,🍎 Only
DOMAIN,metrics.apple.com,🍎 Only
DOMAIN,mvod.itunes.apple.com,🍎 Only
DOMAIN,iosapps.itunes.apple.com,🍎 Only
DOMAIN,init.itunes.apple.com,🍎 Only
DOMAIN,images.apple.com,🍎 Only
DOMAIN,idmsa.apple.com,🍎 Only
DOMAIN,gs-loc.apple.com,🍎 Only
DOMAIN,guzzoni.apple.com,🍎 Only
DOMAIN,configuration.apple.com,🍎 Only
DOMAIN,captive.apple.com,🍎 Only
DOMAIN,appleiphonecell.com,🍎 Only
DOMAIN,appleid.apple.com,🍎 Only
DOMAIN,streamingaudio.itunes.apple.com,🍎 Only
DOMAIN,swscan.apple.com,🍎 Only
DOMAIN,swdist.apple.com,🍎 Only
DOMAIN,swquery.apple.com,🍎 Only
DOMAIN,swdownload.apple.com,🍎 Only
DOMAIN,swcdn.apple.com,🍎 Only
DOMAIN,xp.apple.com,🍎 Only
DOMAIN-SUFFIX,akadns.net,🍎 Only
DOMAIN-SUFFIX,cdn-apple.com,🍎 Only
DOMAIN-SUFFIX,ess.apple.com,🍎 Only
DOMAIN-SUFFIX,lcdn-locator.apple.com,🍎 Only
DOMAIN-SUFFIX,lcdn-registration.apple.com,🍎 Only
DOMAIN-SUFFIX,lookup-api.apple.com,🍎 Only
DOMAIN-SUFFIX,ls.apple.com,🍎 Only
DOMAIN-SUFFIX,mzstatic.com,🍎 Only
DOMAIN-SUFFIX,push-apple.com.akadns.net,🍎 Only
DOMAIN-SUFFIX,push.apple.com,🍎 Only
DOMAIN-SUFFIX,siri.apple.com,🍎 Only
DOMAIN-SUFFIX,aaplimg.com,🍎 Only
DOMAIN-SUFFIX,apple.co,🍎 Only
DOMAIN-SUFFIX,apple.com,🍎 Only
DOMAIN-SUFFIX,icloud-content.com,🍎 Only
DOMAIN-SUFFIX,icloud.com,🍎 Only
DOMAIN-SUFFIX,itunes.apple.com,🍎 Only
DOMAIN-SUFFIX,itunes.com,🍎 Only
DOMAIN-SUFFIX,me.com,🍎 Only

# Yahoo Weather
DOMAIN,m.yap.yahoo.com,REJECT
DOMAIN,geo.yahoo.com,REJECT
DOMAIN,doubleplay-conf-yql.media.yahoo.com,REJECT
DOMAIN-SUFFIX,uservoice.com,REJECT
DOMAIN,ws.progrss.yahoo.com,REJECT
DOMAIN,onepush.query.yahoo.com,REJECT
DOMAIN,locdrop.query.yahoo.com,REJECT
DOMAIN-SUFFIX,comet.yahoo.com,REJECT
DOMAIN-SUFFIX,gemini.yahoo.com,REJECT
DOMAIN,analytics.query.yahoo.com,REJECT

// Client
PROCESS-NAME,Backup and Sync,🍃 Proxy
PROCESS-NAME,Day One,🍃 Proxy
PROCESS-NAME,Dropbox,🍃 Proxy,force-remote-dns
PROCESS-NAME,node-webkit,🍃 Proxy
PROCESS-NAME,Spotify,🍃 Proxy,force-remote-dns
PROCESS-NAME,Telegram,🍃 Proxy,force-remote-dns
PROCESS-NAME,Tweetbot,🍃 Proxy,force-remote-dns
PROCESS-NAME,Twitter,🍃 Proxy,force-remote-dns

// UA
USER-AGENT,*Telegram*,🍃 Proxy,force-remote-dns
USER-AGENT,Argo*,🍃 Proxy
USER-AGENT,Coinbase*,🍃 Proxy
USER-AGENT,Instagram*,🍃 Proxy,force-remote-dns
USER-AGENT,Speedtest*,🍃 Proxy
USER-AGENT,WhatsApp*,🍃 Proxy,force-remote-dns
USER-AGENT,YouTube*,🍃 Proxy,force-remote-dns



# PROXY

// Line
DOMAIN-SUFFIX,lin.ee,🍃 Proxy
DOMAIN-SUFFIX,line.me,🍃 Proxy
DOMAIN-SUFFIX,line.naver.jp,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,line-apps.com,🍃 Proxy
DOMAIN-SUFFIX,line-cdn.net,🍃 Proxy
DOMAIN-SUFFIX,line-scdn.net,🍃 Proxy
DOMAIN-SUFFIX,nhncorp.jp,🍃 Proxy
IP-CIDR,125.209.208.0/20,🍃 Proxy,no-resolve
IP-CIDR,125.209.220.0/22,🍃 Proxy,no-resolve
IP-CIDR,125.209.222.202/32,🍃 Proxy,no-resolve

// MytvSUPER
DOMAIN-KEYWORD,nowtv100,🍃 Proxy
DOMAIN-KEYWORD,rthklive,🍃 Proxy
DOMAIN-SUFFIX,mytvsuper.com,🍃 Proxy
DOMAIN-SUFFIX,tvb.com,🍃 Proxy

// Netflix
DOMAIN-SUFFIX,netflix.com,🍃 Proxy
DOMAIN-SUFFIX,netflix.net,🍃 Proxy
DOMAIN-SUFFIX,nflxext.com,🍃 Proxy
DOMAIN-SUFFIX,nflximg.com,🍃 Proxy
DOMAIN-SUFFIX,nflximg.net,🍃 Proxy
DOMAIN-SUFFIX,nflxvideo.net,🍃 Proxy

// Steam
DOMAIN-SUFFIX,steamcommunity.com,🍃 Proxy
DOMAIN-SUFFIX,steamstatic.com,🍃 Proxy

// Top blocked sites
DOMAIN-SUFFIX,2o7.net,🍃 Proxy
DOMAIN-SUFFIX,4everProxy.com,🍃 Proxy
DOMAIN-SUFFIX,4shared.com,🍃 Proxy
DOMAIN-SUFFIX,4sqi.net,🍃 Proxy
DOMAIN-SUFFIX,9to5mac.com,🍃 Proxy
DOMAIN-SUFFIX,abpchina.org,🍃 Proxy
DOMAIN-SUFFIX,accountkit.com,🍃 Proxy
DOMAIN-SUFFIX,adblockplus.org,🍃 Proxy
DOMAIN-SUFFIX,adobe.com,🍃 Proxy
DOMAIN-SUFFIX,adobedtm.com,🍃 Proxy
DOMAIN-SUFFIX,aerisapi.com,🍃 Proxy
DOMAIN-SUFFIX,akamaihd.net,🍃 Proxy
DOMAIN-SUFFIX,alfredapp.com,🍃 Proxy
DOMAIN-SUFFIX,allconnected.co,🍃 Proxy
DOMAIN-SUFFIX,amazon.com,🍃 Proxy
DOMAIN-SUFFIX,amazonaws.com,🍃 Proxy
DOMAIN-SUFFIX,amplitude.com,🍃 Proxy
DOMAIN-SUFFIX,ampproject.com,🍃 Proxy
DOMAIN-SUFFIX,ampproject.net,🍃 Proxy
DOMAIN-SUFFIX,ampproject.org,🍃 Proxy
DOMAIN-SUFFIX,ancsconf.org,🍃 Proxy
DOMAIN-SUFFIX,android.com,🍃 Proxy
DOMAIN-SUFFIX,androidify.com,🍃 Proxy
DOMAIN-SUFFIX,android-x86.org,🍃 Proxy
DOMAIN-SUFFIX,angularjs.org,🍃 Proxy
DOMAIN-SUFFIX,anthonycalzadilla.com,🍃 Proxy
DOMAIN-SUFFIX,aol.com,🍃 Proxy
DOMAIN-SUFFIX,aolcdn.com,🍃 Proxy
DOMAIN-SUFFIX,apigee.com,🍃 Proxy
DOMAIN-SUFFIX,apk-dl.com,🍃 Proxy
DOMAIN-SUFFIX,apkpure.com,🍃 Proxy
DOMAIN-SUFFIX,appdownloader.net,🍃 Proxy
DOMAIN-SUFFIX,apple-dns.net,🍃 Proxy
DOMAIN-SUFFIX,appshopper.com,🍃 Proxy
DOMAIN-SUFFIX,arcgis.com,🍃 Proxy
DOMAIN-SUFFIX,archive.is,🍃 Proxy
DOMAIN-SUFFIX,archive.org,🍃 Proxy
DOMAIN-SUFFIX,archives.gov,🍃 Proxy
DOMAIN-SUFFIX,armorgames.com,🍃 Proxy
DOMAIN-SUFFIX,aspnetcdn.com,🍃 Proxy
DOMAIN-SUFFIX,async.be,🍃 Proxy
DOMAIN-SUFFIX,att.com,🍃 Proxy
DOMAIN-SUFFIX,awsstatic.com,🍃 Proxy
DOMAIN-SUFFIX,azureedge.net,🍃 Proxy
DOMAIN-SUFFIX,azurewebsites.net,🍃 Proxy
DOMAIN-SUFFIX,bandisoft.com,🍃 Proxy
DOMAIN-SUFFIX,bbtoystore.com,🍃 Proxy
DOMAIN-SUFFIX,betvictor.com,🍃 Proxy
DOMAIN-SUFFIX,bigsound.org,🍃 Proxy
DOMAIN-SUFFIX,bintray.com,🍃 Proxy
DOMAIN-SUFFIX,bit.com,🍃 Proxy
DOMAIN-SUFFIX,bit.do,🍃 Proxy
DOMAIN-SUFFIX,bit.ly,🍃 Proxy
DOMAIN-SUFFIX,bitbucket.org,🍃 Proxy
DOMAIN-SUFFIX,bitcointalk.org,🍃 Proxy
DOMAIN-SUFFIX,bitshare.com,🍃 Proxy
DOMAIN-SUFFIX,bjango.com,🍃 Proxy
DOMAIN-SUFFIX,bkrtx.com,🍃 Proxy
DOMAIN-SUFFIX,blizzard.com,🍃 Proxy
DOMAIN-SUFFIX,blog.com,🍃 Proxy
DOMAIN-SUFFIX,blogcdn.com,🍃 Proxy
DOMAIN-SUFFIX,blogger.com,🍃 Proxy
DOMAIN-SUFFIX,bloglovin.com,🍃 Proxy
DOMAIN-SUFFIX,blogsmithmedia.com,🍃 Proxy
DOMAIN-SUFFIX,blogspot.hk,🍃 Proxy
DOMAIN-SUFFIX,bloomberg.com,🍃 Proxy
DOMAIN-SUFFIX,books.com.tw,🍃 Proxy
DOMAIN-SUFFIX,boomtrain.com,🍃 Proxy
DOMAIN-SUFFIX,box.com,🍃 Proxy
DOMAIN-SUFFIX,box.net,🍃 Proxy
DOMAIN-SUFFIX,boxun.com,🍃 Proxy
DOMAIN-SUFFIX,cachefly.net,🍃 Proxy
DOMAIN-SUFFIX,cbc.ca,🍃 Proxy
DOMAIN-SUFFIX,cdn.segment.com,🍃 Proxy
DOMAIN-SUFFIX,cdnst.net,🍃 Proxy
DOMAIN-SUFFIX,celestrak.com,🍃 Proxy
DOMAIN-SUFFIX,census.gov,🍃 Proxy
DOMAIN-SUFFIX,certificate-transparency.org,🍃 Proxy
DOMAIN-SUFFIX,chinatimes.com,🍃 Proxy
DOMAIN-SUFFIX,chrome.com,🍃 Proxy
DOMAIN-SUFFIX,chromecast.com,🍃 Proxy
DOMAIN-SUFFIX,chromercise.com,🍃 Proxy
DOMAIN-SUFFIX,chromestatus.com,🍃 Proxy
DOMAIN-SUFFIX,chromium.org,🍃 Proxy
DOMAIN-SUFFIX,cl.ly,🍃 Proxy
DOMAIN-SUFFIX,cloudflare.com,🍃 Proxy
DOMAIN-SUFFIX,cloudfront.net,🍃 Proxy
DOMAIN-SUFFIX,cloudmagic.com,🍃 Proxy
DOMAIN-SUFFIX,cmail19.com,🍃 Proxy
DOMAIN-SUFFIX,cnet.com,🍃 Proxy
DOMAIN-SUFFIX,cnn.com,🍃 Proxy
DOMAIN-SUFFIX,cocoapods.org,🍃 Proxy
DOMAIN-SUFFIX,comodoca.com,🍃 Proxy
DOMAIN-SUFFIX,content.office.net,🍃 Proxy
DOMAIN-SUFFIX,d.pr,🍃 Proxy
DOMAIN-SUFFIX,danilo.to,🍃 Proxy
DOMAIN-SUFFIX,daolan.net,🍃 Proxy
DOMAIN-SUFFIX,data-vocabulary.org,🍃 Proxy
DOMAIN-SUFFIX,dayone.me,🍃 Proxy
DOMAIN-SUFFIX,db.tt,🍃 Proxy
DOMAIN-SUFFIX,dcmilitary.com,🍃 Proxy
DOMAIN-SUFFIX,deja.com,🍃 Proxy
DOMAIN-SUFFIX,demdex.net,🍃 Proxy
DOMAIN-SUFFIX,deskconnect.com,🍃 Proxy
DOMAIN-SUFFIX,digicert.com,🍃 Proxy
DOMAIN-SUFFIX,digisfera.com,🍃 Proxy
DOMAIN-SUFFIX,digitaltrends.com,🍃 Proxy
DOMAIN-SUFFIX,disconnect.me,🍃 Proxy
DOMAIN-SUFFIX,disq.us,🍃 Proxy
DOMAIN-SUFFIX,disqus.com,🍃 Proxy
DOMAIN-SUFFIX,disquscdn.com,🍃 Proxy
DOMAIN-SUFFIX,dnsimple.com,🍃 Proxy
DOMAIN-SUFFIX,docker.com,🍃 Proxy
DOMAIN-SUFFIX,dribbble.com,🍃 Proxy
DOMAIN-SUFFIX,droplr.com,🍃 Proxy
DOMAIN-SUFFIX,duckduckgo.com,🍃 Proxy
DOMAIN-SUFFIX,dueapp.com,🍃 Proxy
DOMAIN-SUFFIX,dw.com,🍃 Proxy
DOMAIN-SUFFIX,easybib.com,🍃 Proxy
DOMAIN-SUFFIX,economist.com,🍃 Proxy
DOMAIN-SUFFIX,edgecastcdn.net,🍃 Proxy
DOMAIN-SUFFIX,edgekey.net,🍃 Proxy
DOMAIN-SUFFIX,edgesuite.net,🍃 Proxy
DOMAIN-SUFFIX,engadget.com,🍃 Proxy
DOMAIN-SUFFIX,entrust.net,🍃 Proxy
DOMAIN-SUFFIX,eurekavpt.com,🍃 Proxy
DOMAIN-SUFFIX,evernote.com,🍃 Proxy
DOMAIN-SUFFIX,extmatrix.com,🍃 Proxy
DOMAIN-SUFFIX,eyny.com,🍃 Proxy
DOMAIN-SUFFIX,fabric.io,🍃 Proxy
DOMAIN-SUFFIX,fast.com,🍃 Proxy
DOMAIN-SUFFIX,fastly.net,🍃 Proxy
DOMAIN-SUFFIX,fc2.com,🍃 Proxy
DOMAIN-SUFFIX,feedburner.com,🍃 Proxy
DOMAIN-SUFFIX,feedly.com,🍃 Proxy
DOMAIN-SUFFIX,feedsportal.com,🍃 Proxy
DOMAIN-SUFFIX,fiftythree.com,🍃 Proxy
DOMAIN-SUFFIX,firebaseio.com,🍃 Proxy
DOMAIN-SUFFIX,flexibits.com,🍃 Proxy
DOMAIN-SUFFIX,flickr.com,🍃 Proxy
DOMAIN-SUFFIX,flipboard.com,🍃 Proxy
DOMAIN-SUFFIX,flipkart.com,🍃 Proxy
DOMAIN-SUFFIX,flitto.com,🍃 Proxy
DOMAIN-SUFFIX,freeopenProxy.com,🍃 Proxy
DOMAIN-SUFFIX,fullstory.com,🍃 Proxy
DOMAIN-SUFFIX,fzlm.net,🍃 Proxy
DOMAIN-SUFFIX,g.co,🍃 Proxy
DOMAIN-SUFFIX,gabia.net,🍃 Proxy
DOMAIN-SUFFIX,garena.com,🍃 Proxy
DOMAIN-SUFFIX,geni.us,🍃 Proxy
DOMAIN-SUFFIX,get.how,🍃 Proxy
DOMAIN-SUFFIX,getcloudapp.com,🍃 Proxy
DOMAIN-SUFFIX,getfoxyProxy.org,🍃 Proxy
DOMAIN-SUFFIX,getlantern.org,🍃 Proxy
DOMAIN-SUFFIX,getmdl.io,🍃 Proxy
DOMAIN-SUFFIX,getpricetag.com,🍃 Proxy
DOMAIN-SUFFIX,gfw.press,🍃 Proxy
DOMAIN-SUFFIX,gfx.ms,🍃 Proxy
DOMAIN-SUFFIX,ggpht.com,🍃 Proxy
DOMAIN-SUFFIX,ghostnoteapp.com,🍃 Proxy
DOMAIN-SUFFIX,git.io,🍃 Proxy
DOMAIN-SUFFIX,github.com,🍃 Proxy
DOMAIN-SUFFIX,github.io,🍃 Proxy
DOMAIN-SUFFIX,githubapp.com,🍃 Proxy
DOMAIN-SUFFIX,githubusercontent.com,🍃 Proxy
DOMAIN-SUFFIX,globalsign.com,🍃 Proxy
DOMAIN-SUFFIX,gmodules.com,🍃 Proxy
DOMAIN-SUFFIX,go.com,🍃 Proxy
DOMAIN-SUFFIX,go.jp,🍃 Proxy
DOMAIN-SUFFIX,godaddy.com,🍃 Proxy
DOMAIN-SUFFIX,golang.org,🍃 Proxy
DOMAIN-SUFFIX,gongm.in,🍃 Proxy
DOMAIN-SUFFIX,goo.gl,🍃 Proxy
DOMAIN-SUFFIX,goodreaders.com,🍃 Proxy
DOMAIN-SUFFIX,goodreads.com,🍃 Proxy
DOMAIN-SUFFIX,gravatar.com,🍃 Proxy
DOMAIN-SUFFIX,gstatic.cn,🍃 Proxy
DOMAIN-SUFFIX,gstatic.com,🍃 Proxy
DOMAIN-SUFFIX,gunsamerica.com,🍃 Proxy
DOMAIN-SUFFIX,gvt0.com,🍃 Proxy
DOMAIN-SUFFIX,helpshift.com,🍃 Proxy
DOMAIN-SUFFIX,hockeyapp.net,🍃 Proxy
DOMAIN-SUFFIX,homedepot.com,🍃 Proxy
DOMAIN-SUFFIX,hootsuite.com,🍃 Proxy
DOMAIN-SUFFIX,hotmail.com,🍃 Proxy
DOMAIN-SUFFIX,howtoforge.com,🍃 Proxy
DOMAIN-SUFFIX,iam.soy,🍃 Proxy
DOMAIN-SUFFIX,icoco.com,🍃 Proxy
DOMAIN-SUFFIX,icons8.com,🍃 Proxy
DOMAIN-SUFFIX,ift.tt,🍃 Proxy
DOMAIN-SUFFIX,ifttt.com,🍃 Proxy
DOMAIN-SUFFIX,imageshack.us,🍃 Proxy
DOMAIN-SUFFIX,img.ly,🍃 Proxy
DOMAIN-SUFFIX,imgur.com,🍃 Proxy
DOMAIN-SUFFIX,imore.com,🍃 Proxy
DOMAIN-SUFFIX,ingress.com ,🍃 Proxy
DOMAIN-SUFFIX,insder.co,🍃 Proxy
DOMAIN-SUFFIX,instapaper.com,🍃 Proxy
DOMAIN-SUFFIX,instructables.com,🍃 Proxy
DOMAIN-SUFFIX,io.io,🍃 Proxy
DOMAIN-SUFFIX,ipn.li,🍃 Proxy
DOMAIN-SUFFIX,is.gd,🍃 Proxy
DOMAIN-SUFFIX,issuu.com,🍃 Proxy
DOMAIN-SUFFIX,itgonglun.com,🍃 Proxy
DOMAIN-SUFFIX,itun.es,🍃 Proxy
DOMAIN-SUFFIX,ixquick.com,🍃 Proxy
DOMAIN-SUFFIX,j.mp,🍃 Proxy
DOMAIN-SUFFIX,js.revsci.net,🍃 Proxy
DOMAIN-SUFFIX,jshint.com,🍃 Proxy
DOMAIN-SUFFIX,jtvnw.net,🍃 Proxy
DOMAIN-SUFFIX,justgetflux.com,🍃 Proxy
DOMAIN-SUFFIX,kakao.co.kr,🍃 Proxy
DOMAIN-SUFFIX,kakao.com,🍃 Proxy
DOMAIN-SUFFIX,kakaocdn.net,🍃 Proxy
DOMAIN-SUFFIX,kat.cr,🍃 Proxy
DOMAIN-SUFFIX,kenengba.com,🍃 Proxy
DOMAIN-SUFFIX,klip.me,🍃 Proxy
DOMAIN-SUFFIX,leancloud.com,🍃 Proxy
DOMAIN-SUFFIX,leetcode.com,🍃 Proxy
DOMAIN-SUFFIX,libsyn.com,🍃 Proxy
DOMAIN-SUFFIX,licdn.com,🍃 Proxy
DOMAIN-SUFFIX,lightboxcdn.com,🍃 Proxy
DOMAIN-SUFFIX,like.com,🍃 Proxy
DOMAIN-SUFFIX,linkedin.com,🍃 Proxy
DOMAIN-SUFFIX,linode.com,🍃 Proxy
DOMAIN-SUFFIX,lithium.com,🍃 Proxy
DOMAIN-SUFFIX,littlehj.com,🍃 Proxy
DOMAIN-SUFFIX,live.net,🍃 Proxy
DOMAIN-SUFFIX,livefilestore.com,🍃 Proxy
DOMAIN-SUFFIX,llnwd.net,🍃 Proxy
DOMAIN-SUFFIX,logmein.com,🍃 Proxy
DOMAIN-SUFFIX,macid.co,🍃 Proxy
DOMAIN-SUFFIX,macromedia.com,🍃 Proxy
DOMAIN-SUFFIX,macrumors.com,🍃 Proxy
DOMAIN-SUFFIX,marketwatch.com,🍃 Proxy
DOMAIN-SUFFIX,mashable.com,🍃 Proxy
DOMAIN-SUFFIX,mathjax.org,🍃 Proxy
DOMAIN-SUFFIX,medium.com,🍃 Proxy
DOMAIN-SUFFIX,mega.co.nz,🍃 Proxy
DOMAIN-SUFFIX,mega.nz,🍃 Proxy
DOMAIN-SUFFIX,megaupload.com,🍃 Proxy
DOMAIN-SUFFIX,microsoft.com,🍃 Proxy
DOMAIN-SUFFIX,microsofttranslator.com,🍃 Proxy
DOMAIN-SUFFIX,mindnode.com,🍃 Proxy
DOMAIN-SUFFIX,mlssoccer.com,🍃 Proxy
DOMAIN-SUFFIX,mobile01.com,🍃 Proxy
DOMAIN-SUFFIX,modmyi.com,🍃 Proxy
DOMAIN-SUFFIX,mp3buscador.com,🍃 Proxy
DOMAIN-SUFFIX,msedge.net,🍃 Proxy
DOMAIN-SUFFIX,mycnnews.com,🍃 Proxy
DOMAIN-SUFFIX,myfontastic.com,🍃 Proxy
DOMAIN-SUFFIX,name.com,🍃 Proxy
DOMAIN-SUFFIX,nasa.gov,🍃 Proxy
DOMAIN-SUFFIX,ndr.de,🍃 Proxy
DOMAIN-SUFFIX,netdna-cdn.com,🍃 Proxy
DOMAIN-SUFFIX,newipnow.com,🍃 Proxy
DOMAIN-SUFFIX,nextmedia.com,🍃 Proxy
DOMAIN-SUFFIX,nih.gov,🍃 Proxy
DOMAIN-SUFFIX,nintendo.com,🍃 Proxy
DOMAIN-SUFFIX,nintendo.net,🍃 Proxy
DOMAIN-SUFFIX,notion.so,🍃 Proxy
DOMAIN-SUFFIX,nrk.no,🍃 Proxy
DOMAIN-SUFFIX,nsstatic.net,🍃 Proxy
DOMAIN-SUFFIX,nssurge.com,🍃 Proxy
DOMAIN-SUFFIX,nyt.com,🍃 Proxy
DOMAIN-SUFFIX,nytimes.com,🍃 Proxy
DOMAIN-SUFFIX,nytimg.com,🍃 Proxy
DOMAIN-SUFFIX,nytstyle.com,🍃 Proxy
DOMAIN-SUFFIX,office365.com,🍃 Proxy
DOMAIN-SUFFIX,omnigroup.com,🍃 Proxy
DOMAIN-SUFFIX,onedrive.com,🍃 Proxy
DOMAIN-SUFFIX,onedrive.live.com,🍃 Proxy
DOMAIN-SUFFIX,onenote.com,🍃 Proxy
DOMAIN-SUFFIX,ooyala.com,🍃 Proxy
DOMAIN-SUFFIX,openvpn.net,🍃 Proxy
DOMAIN-SUFFIX,openwrt.org,🍃 Proxy
DOMAIN-SUFFIX,optimizely.com,🍃 Proxy
DOMAIN-SUFFIX,orkut.com,🍃 Proxy
DOMAIN-SUFFIX,osha.gov,🍃 Proxy
DOMAIN-SUFFIX,osxdaily.com,🍃 Proxy
DOMAIN-SUFFIX,ow.ly,🍃 Proxy
DOMAIN-SUFFIX,paddle.com,🍃 Proxy
DOMAIN-SUFFIX,paddleapi.com,🍃 Proxy
DOMAIN-SUFFIX,panoramio.com,🍃 Proxy
DOMAIN-SUFFIX,parallels.com,🍃 Proxy
DOMAIN-SUFFIX,parse.com,🍃 Proxy
DOMAIN-SUFFIX,pdfexpert.com,🍃 Proxy
DOMAIN-SUFFIX,periscope.tv,🍃 Proxy
DOMAIN-SUFFIX,piaotian.net,🍃 Proxy
DOMAIN-SUFFIX,picasaweb.com,🍃 Proxy
DOMAIN-SUFFIX,pinboard.in,🍃 Proxy
DOMAIN-SUFFIX,pinterest.com,🍃 Proxy
DOMAIN-SUFFIX,pixelmator.com,🍃 Proxy
DOMAIN-SUFFIX,pixnet.net,🍃 Proxy
DOMAIN-SUFFIX,playpcesor.com,🍃 Proxy
DOMAIN-SUFFIX,playstation.com,🍃 Proxy
DOMAIN-SUFFIX,playstation.com.hk,🍃 Proxy
DOMAIN-SUFFIX,playstation.net,🍃 Proxy
DOMAIN-SUFFIX,playstationnetwork.com,🍃 Proxy
DOMAIN-SUFFIX,pokemon.com,🍃 Proxy
DOMAIN-SUFFIX,polymer-project.org,🍃 Proxy
DOMAIN-SUFFIX,popo.tw,🍃 Proxy
DOMAIN-SUFFIX,prfct.co,🍃 Proxy
DOMAIN-SUFFIX,proxfree.com,🍃 Proxy
DOMAIN-SUFFIX,psiphon3.com,🍃 Proxy
DOMAIN-SUFFIX,ptt.cc,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,pubu.com.tw,🍃 Proxy
DOMAIN-SUFFIX,puffinbrowser.com,🍃 Proxy
DOMAIN-SUFFIX,pushwoosh.com,🍃 Proxy
DOMAIN-SUFFIX,pximg.net,🍃 Proxy
DOMAIN-SUFFIX,readingtimes.com.tw,🍃 Proxy
DOMAIN-SUFFIX,readmoo.com,🍃 Proxy
DOMAIN-SUFFIX,recaptcha.net,🍃 Proxy
DOMAIN-SUFFIX,reuters.com,🍃 Proxy
DOMAIN-SUFFIX,rfi.fr,🍃 Proxy
DOMAIN-SUFFIX,rileyguide.com,🍃 Proxy
DOMAIN-SUFFIX,rime.im,🍃 Proxy
DOMAIN-SUFFIX,rsf.org,🍃 Proxy
DOMAIN-SUFFIX,sciencedaily.com,🍃 Proxy
DOMAIN-SUFFIX,sciencemag.org,🍃 Proxy
DOMAIN-SUFFIX,scribd.com,🍃 Proxy
DOMAIN-SUFFIX,search.com,🍃 Proxy
DOMAIN-SUFFIX,servebom.com,🍃 Proxy
DOMAIN-SUFFIX,sfx.ms,🍃 Proxy
DOMAIN-SUFFIX,shadowsocks.org,🍃 Proxy
DOMAIN-SUFFIX,sharethis.com,🍃 Proxy
DOMAIN-SUFFIX,shazam.com,🍃 Proxy
DOMAIN-SUFFIX,shutterstock.com,🍃 Proxy
DOMAIN-SUFFIX,sidelinesnews.com,🍃 Proxy
DOMAIN-SUFFIX,simp.ly,🍃 Proxy
DOMAIN-SUFFIX,simplenote.com,🍃 Proxy
DOMAIN-SUFFIX,sketchappsources.com,🍃 Proxy
DOMAIN-SUFFIX,skype.com,🍃 Proxy
DOMAIN-SUFFIX,slack.com,🍃 Proxy
DOMAIN-SUFFIX,slack-edge.com,🍃 Proxy
DOMAIN-SUFFIX,slack-msgs.com,🍃 Proxy
DOMAIN-SUFFIX,slideshare.net,🍃 Proxy
DOMAIN-SUFFIX,smartdnsproxy.com,🍃 Proxy
DOMAIN-SUFFIX,smartmailcloud.com,🍃 Proxy
DOMAIN-SUFFIX,smh.com.au,🍃 Proxy
DOMAIN-SUFFIX,snapchat.com,🍃 Proxy
DOMAIN-SUFFIX,sndcdn.com,🍃 Proxy
DOMAIN-SUFFIX,sockslist.net,🍃 Proxy
DOMAIN-SUFFIX,sony.com,🍃 Proxy
DOMAIN-SUFFIX,sony.com.hk,🍃 Proxy
DOMAIN-SUFFIX,sonyentertainmentnetwork.com,🍃 Proxy
DOMAIN-SUFFIX,soundcloud.com,🍃 Proxy
DOMAIN-SUFFIX,sourceforge.net,🍃 Proxy
DOMAIN-SUFFIX,sowers.org.hk,🍃 Proxy
DOMAIN-SUFFIX,speedsmart.net,🍃 Proxy
DOMAIN-SUFFIX,spike.com,🍃 Proxy
DOMAIN-SUFFIX,spoti.fi,🍃 Proxy
DOMAIN-SUFFIX,squarespace.com,🍃 Proxy
DOMAIN-SUFFIX,ssa.gov,🍃 Proxy
DOMAIN-SUFFIX,sstatic.net,🍃 Proxy
DOMAIN-SUFFIX,st.luluku.pw,🍃 Proxy
DOMAIN-SUFFIX,stackoverflow.com,🍃 Proxy
DOMAIN-SUFFIX,starp2p.com,🍃 Proxy
DOMAIN-SUFFIX,startpage.com,🍃 Proxy
DOMAIN-SUFFIX,state.gov,🍃 Proxy
DOMAIN-SUFFIX,staticflickr.com,🍃 Proxy
DOMAIN-SUFFIX,storify.com,🍃 Proxy
DOMAIN-SUFFIX,stumbleupon.com,🍃 Proxy
DOMAIN-SUFFIX,sugarsync.com,🍃 Proxy
DOMAIN-SUFFIX,supermariorun.com,🍃 Proxy
DOMAIN-SUFFIX,surfeasy.com.au,🍃 Proxy
DOMAIN-SUFFIX,surge.run,🍃 Proxy
DOMAIN-SUFFIX,surrenderat20.net,🍃 Proxy
DOMAIN-SUFFIX,sydneytoday.com,🍃 Proxy
DOMAIN-SUFFIX,symauth.com,🍃 Proxy
DOMAIN-SUFFIX,symcb.com,🍃 Proxy
DOMAIN-SUFFIX,symcd.com,🍃 Proxy
DOMAIN-SUFFIX,t.me,🍃 Proxy
DOMAIN-SUFFIX,tablesgenerator.com,🍃 Proxy
DOMAIN-SUFFIX,tabtter.jp,🍃 Proxy
DOMAIN-SUFFIX,talk853.com,🍃 Proxy
DOMAIN-SUFFIX,talkboxapp.com,🍃 Proxy
DOMAIN-SUFFIX,talkonly.net,🍃 Proxy
DOMAIN-SUFFIX,tapbots.com,🍃 Proxy
DOMAIN-SUFFIX,tapbots.net,🍃 Proxy
DOMAIN-SUFFIX,tdesktop.com,🍃 Proxy
DOMAIN-SUFFIX,teamviewer.com,🍃 Proxy
DOMAIN-SUFFIX,techcrunch.com,🍃 Proxy
DOMAIN-SUFFIX,technorati.com,🍃 Proxy
DOMAIN-SUFFIX,techsmith.com,🍃 Proxy
DOMAIN-SUFFIX,telegra.ph,🍃 Proxy
DOMAIN-SUFFIX,thebobs.com,🍃 Proxy
DOMAIN-SUFFIX,thepiratebay.org,🍃 Proxy
DOMAIN-SUFFIX,theverge.com,🍃 Proxy
DOMAIN-SUFFIX,thewgo.org,🍃 Proxy
DOMAIN-SUFFIX,tiltbrush.com,🍃 Proxy
DOMAIN-SUFFIX,tinder.com,🍃 Proxy
DOMAIN-SUFFIX,time.com,🍃 Proxy
DOMAIN-SUFFIX,timeinc.net,🍃 Proxy
DOMAIN-SUFFIX,tiny.cc,🍃 Proxy
DOMAIN-SUFFIX,tinychat.com,🍃 Proxy
DOMAIN-SUFFIX,tinypic.com,🍃 Proxy
DOMAIN-SUFFIX,tmblr.co,🍃 Proxy
DOMAIN-SUFFIX,todoist.com,🍃 Proxy
DOMAIN-SUFFIX,togetter.com,🍃 Proxy
DOMAIN-SUFFIX,tokyocn.com,🍃 Proxy
DOMAIN-SUFFIX,tomshardware.com,🍃 Proxy
DOMAIN-SUFFIX,torcn.com,🍃 Proxy
DOMAIN-SUFFIX,torrentprivacy.com,🍃 Proxy
DOMAIN-SUFFIX,torrentproject.se,🍃 Proxy
DOMAIN-SUFFIX,torrentz.eu,🍃 Proxy
DOMAIN-SUFFIX,traffichaus.com,🍃 Proxy
DOMAIN-SUFFIX,transparency.org,🍃 Proxy
DOMAIN-SUFFIX,trello.com,🍃 Proxy
DOMAIN-SUFFIX,trendsmap.com,🍃 Proxy
DOMAIN-SUFFIX,trulyergonomic.com,🍃 Proxy
DOMAIN-SUFFIX,trustasiassl.com,🍃 Proxy
DOMAIN-SUFFIX,tt-rss.org,🍃 Proxy
DOMAIN-SUFFIX,tumblr.co,🍃 Proxy
DOMAIN-SUFFIX,tumblr.com,🍃 Proxy
DOMAIN-SUFFIX,turbobit.net,🍃 Proxy
DOMAIN-SUFFIX,tv.com,🍃 Proxy
DOMAIN-SUFFIX,tweetdeck.com,🍃 Proxy
DOMAIN-SUFFIX,tweetmarker.net,🍃 Proxy
DOMAIN-SUFFIX,twimg.co,🍃 Proxy
DOMAIN-SUFFIX,twitch.tv,🍃 Proxy
DOMAIN-SUFFIX,twitthat.com,🍃 Proxy
DOMAIN-SUFFIX,twtkr.com,🍃 Proxy
DOMAIN-SUFFIX,twttr.com,🍃 Proxy
DOMAIN-SUFFIX,txmblr.com,🍃 Proxy
DOMAIN-SUFFIX,typekit.net,🍃 Proxy
DOMAIN-SUFFIX,typography.com,🍃 Proxy
DOMAIN-SUFFIX,ubertags.com,🍃 Proxy
DOMAIN-SUFFIX,ublock.org,🍃 Proxy
DOMAIN-SUFFIX,ubnt.com,🍃 Proxy
DOMAIN-SUFFIX,uchicago.edu,🍃 Proxy
DOMAIN-SUFFIX,udn.com,🍃 Proxy
DOMAIN-SUFFIX,ugo.com,🍃 Proxy
DOMAIN-SUFFIX,uhdwallpapers.org,🍃 Proxy
DOMAIN-SUFFIX,ulyssesapp.com,🍃 Proxy
DOMAIN-SUFFIX,unblockdmm.com,🍃 Proxy
DOMAIN-SUFFIX,unblocksites.co,🍃 Proxy
DOMAIN-SUFFIX,unpo.org,🍃 Proxy
DOMAIN-SUFFIX,untraceable.us,🍃 Proxy
DOMAIN-SUFFIX,uploaded.net,🍃 Proxy
DOMAIN-SUFFIX,uProxy.org,🍃 Proxy
DOMAIN-SUFFIX,urchin.com,🍃 Proxy
DOMAIN-SUFFIX,urlparser.com,🍃 Proxy
DOMAIN-SUFFIX,us.to,🍃 Proxy
DOMAIN-SUFFIX,usertrust.com,🍃 Proxy
DOMAIN-SUFFIX,usgs.gov,🍃 Proxy
DOMAIN-SUFFIX,usma.edu,🍃 Proxy
DOMAIN-SUFFIX,uspto.gov,🍃 Proxy
DOMAIN-SUFFIX,ustream.tv,🍃 Proxy
DOMAIN-SUFFIX,v.gd,🍃 Proxy
DOMAIN-SUFFIX,v2ray.com,🍃 Proxy
DOMAIN-SUFFIX,van001.com,🍃 Proxy
DOMAIN-SUFFIX,vanpeople.com,🍃 Proxy
DOMAIN-SUFFIX,vansky.com,🍃 Proxy
DOMAIN-SUFFIX,vbstatic.co,🍃 Proxy
DOMAIN-SUFFIX,venchina.com,🍃 Proxy
DOMAIN-SUFFIX,venturebeat.com,🍃 Proxy
DOMAIN-SUFFIX,veoh.com,🍃 Proxy
DOMAIN-SUFFIX,verizonwireless.com,🍃 Proxy
DOMAIN-SUFFIX,viber.com,🍃 Proxy
DOMAIN-SUFFIX,vid.me,🍃 Proxy
DOMAIN-SUFFIX,videomega.tv,🍃 Proxy
DOMAIN-SUFFIX,vidinfo.org,🍃 Proxy
DOMAIN-SUFFIX,vimeo.com,🍃 Proxy
DOMAIN-SUFFIX,vimeocdn.com,🍃 Proxy
DOMAIN-SUFFIX,vimperator.org,🍃 Proxy
DOMAIN-SUFFIX,vine.co,🍃 Proxy
DOMAIN-SUFFIX,visibletweets.com,🍃 Proxy
DOMAIN-SUFFIX,vivaldi.com,🍃 Proxy
DOMAIN-SUFFIX,voachinese.com,🍃 Proxy
DOMAIN-SUFFIX,vocativ.com,🍃 Proxy
DOMAIN-SUFFIX,vox-cdn.com,🍃 Proxy
DOMAIN-SUFFIX,vpnaccount.org,🍃 Proxy
DOMAIN-SUFFIX,vpnbook.com,🍃 Proxy
DOMAIN-SUFFIX,vpngate.net,🍃 Proxy
DOMAIN-SUFFIX,vsco.co,🍃 Proxy
DOMAIN-SUFFIX,vultr.com,🍃 Proxy
DOMAIN-SUFFIX,vzw.com,🍃 Proxy
DOMAIN-SUFFIX,w.org,🍃 Proxy
DOMAIN-SUFFIX,w3schools.com,🍃 Proxy
DOMAIN-SUFFIX,wattpad.com,🍃 Proxy
DOMAIN-SUFFIX,web2project.net,🍃 Proxy
DOMAIN-SUFFIX,webfreer.com,🍃 Proxy
DOMAIN-SUFFIX,weblagu.com,🍃 Proxy
DOMAIN-SUFFIX,websnapr.com,🍃 Proxy
DOMAIN-SUFFIX,webtype.com,🍃 Proxy
DOMAIN-SUFFIX,webwarper.net,🍃 Proxy
DOMAIN-SUFFIX,wenxuecity.com,🍃 Proxy
DOMAIN-SUFFIX,westca.com,🍃 Proxy
DOMAIN-SUFFIX,westpoint.edu,🍃 Proxy
DOMAIN-SUFFIX,whatbrowser.org,🍃 Proxy
DOMAIN-SUFFIX,wikileaks.info,🍃 Proxy
DOMAIN-SUFFIX,wikileaks.org,🍃 Proxy
DOMAIN-SUFFIX,wikileaks-forum.com,🍃 Proxy
DOMAIN-SUFFIX,wikimedia.org,🍃 Proxy
DOMAIN-SUFFIX,wikipedia.com,🍃 Proxy
DOMAIN-SUFFIX,wikipedia.org,🍃 Proxy
DOMAIN-SUFFIX,windows.com,🍃 Proxy
DOMAIN-SUFFIX,windows.net,🍃 Proxy
DOMAIN-SUFFIX,wn.com,🍃 Proxy
DOMAIN-SUFFIX,wordpress.com,🍃 Proxy
DOMAIN-SUFFIX,workflow.is,🍃 Proxy
DOMAIN-SUFFIX,worldcat.org,🍃 Proxy
DOMAIN-SUFFIX,wow.com,🍃 Proxy
DOMAIN-SUFFIX,wp.com,🍃 Proxy
DOMAIN-SUFFIX,wsj.com,🍃 Proxy
DOMAIN-SUFFIX,wsj.net,🍃 Proxy
DOMAIN-SUFFIX,wwitv.com,🍃 Proxy
DOMAIN-SUFFIX,xanga.com,🍃 Proxy
DOMAIN-SUFFIX,xda-developers.com,🍃 Proxy
DOMAIN-SUFFIX,xeeno.com,🍃 Proxy
DOMAIN-SUFFIX,xiti.com,🍃 Proxy
DOMAIN-SUFFIX,xn--h5qz41fzgdxxl.com,🍃 Proxy
DOMAIN-SUFFIX,xuite.net,🍃 Proxy
DOMAIN-SUFFIX,yahoo.com,🍃 Proxy
DOMAIN-SUFFIX,yahooapis.com,🍃 Proxy
DOMAIN-SUFFIX,yasni.co.uk,🍃 Proxy
DOMAIN-SUFFIX,yastatic.net,🍃 Proxy
DOMAIN-SUFFIX,yeeyi.com,🍃 Proxy
DOMAIN-SUFFIX,yesasia.com,🍃 Proxy
DOMAIN-SUFFIX,yes-news.com,🍃 Proxy
DOMAIN-SUFFIX,yidio.com,🍃 Proxy
DOMAIN-SUFFIX,yimg.com,🍃 Proxy
DOMAIN-SUFFIX,ying.com,🍃 Proxy
DOMAIN-SUFFIX,yorkbbs.ca,🍃 Proxy
DOMAIN-SUFFIX,youmaker.com,🍃 Proxy
DOMAIN-SUFFIX,yourlisten.com,🍃 Proxy
DOMAIN-SUFFIX,youtu.be,🍃 Proxy
DOMAIN-SUFFIX,yoyo.org,🍃 Proxy
DOMAIN-SUFFIX,ytimg.com,🍃 Proxy
DOMAIN-SUFFIX,zacebook.com,🍃 Proxy
DOMAIN-SUFFIX,zalmos.com,🍃 Proxy
DOMAIN-SUFFIX,zaobao.com.sg,🍃 Proxy
DOMAIN-SUFFIX,zeutch.com,🍃 Proxy
DOMAIN-SUFFIX,zynamics.com,🍃 Proxy

// LINE
IP-CIDR,103.2.28.0/22,🍃 Proxy,no-resolve
IP-CIDR,119.235.224.0/21,🍃 Proxy,no-resolve
IP-CIDR,119.235.232.0/23,🍃 Proxy,no-resolve
IP-CIDR,119.235.235.0/24,🍃 Proxy,no-resolve
IP-CIDR,119.235.236.0/23,🍃 Proxy,no-resolve
IP-CIDR,125.6.146.0/24,🍃 Proxy,no-resolve
IP-CIDR,125.6.149.0/24,🍃 Proxy,no-resolve
IP-CIDR,125.6.190.0/24,🍃 Proxy,no-resolve
IP-CIDR,203.104.103.0/24,🍃 Proxy,no-resolve
IP-CIDR,203.104.128.0/20,🍃 Proxy,no-resolve
IP-CIDR,203.174.66.64/26,🍃 Proxy,no-resolve
IP-CIDR,203.174.77.0/24,🍃 Proxy,no-resolve

// Telegram
IP-CIDR,109.239.140.0/24,🍃 Proxy,no-resolve
IP-CIDR,149.154.160.0/20,🍃 Proxy,no-resolve
IP-CIDR,91.108.4.0/16,🍃 Proxy,no-resolve
IP-CIDR6,2001:67c:4e8::/48,REJECT,no-resolve
IP-CIDR6,2001:b28:f23d::/48,REJECT,no-resolve
IP-CIDR6,2001:b28:f23f::/48,REJECT,no-resolve

// Kakao Talk
IP-CIDR,1.201.0.0/24,🍃 Proxy,no-resolve
IP-CIDR,103.246.56.0/22,🍃 Proxy,no-resolve
IP-CIDR,103.27.148.0/22,🍃 Proxy,no-resolve
IP-CIDR,110.76.140.0/22,🍃 Proxy,no-resolve
IP-CIDR,113.61.104.0/22,🍃 Proxy,no-resolve
IP-CIDR,27.0.236.0/22,🍃 Proxy,no-resolve


// Client
PROCESS-NAME,Paws for Trello,🍂 Domestic
PROCESS-NAME,Thunder,🍂 Domestic
PROCESS-NAME,trustd,🍂 Domestic
PROCESS-NAME,WeChat,🍂 Domestic

// UA
USER-AGENT,%E5%8D%B3%E5%88%BB*,🍂 Domestic
USER-AGENT,*Vainglory* ,🍂 Domestic
USER-AGENT,AdBlock*,🍂 Domestic
USER-AGENT,arrowio*,🍂 Domestic
USER-AGENT,balls*,🍂 Domestic
USER-AGENT,cmblife*,🍂 Domestic
USER-AGENT,hide*,🍂 Domestic
USER-AGENT,MegaWerewolf*,🍂 Domestic
USER-AGENT,MicroMessenger*,🍂 Domestic
USER-AGENT,Moke*,🍂 Domestic
USER-AGENT,osee2unifiedRelease*,🍂 Domestic
USER-AGENT,QQ*,🍂 Domestic
USER-AGENT,TeamViewer*,🍂 Domestic
USER-AGENT,TIM*,🍂 Domestic
USER-AGENT,WeChat*,🍂 Domestic

# DIRECT

// Spark
DOMAIN-SUFFIX,api.amplitude.com,🍂 Domestic
DOMAIN-SUFFIX,app.smartmailcloud.com,🍂 Domestic
DOMAIN-SUFFIX,firebaseio.com,🍂 Domestic
DOMAIN-SUFFIX,gate.hockeyapp.net,🍂 Domestic

DOMAIN-SUFFIX,12306.com,🍂 Domestic
DOMAIN-SUFFIX,126.net,🍂 Domestic
DOMAIN-SUFFIX,163.com,🍂 Domestic
DOMAIN-SUFFIX,360.cn,🍂 Domestic
DOMAIN-SUFFIX,360.com,🍂 Domestic
DOMAIN-SUFFIX,360buy.com,🍂 Domestic
DOMAIN-SUFFIX,360buyimg.com,🍂 Domestic
DOMAIN-SUFFIX,36kr.com,🍂 Domestic
DOMAIN-SUFFIX,58.com,🍂 Domestic
DOMAIN-SUFFIX,abercrombie.com,🍂 Domestic
DOMAIN-SUFFIX,acfun.tv,🍂 Domestic
DOMAIN-SUFFIX,acgvideo.com,🍂 Domestic
DOMAIN-SUFFIX,adobesc.com,🍂 Domestic
DOMAIN-SUFFIX,air-matters.com,🍂 Domestic
DOMAIN-SUFFIX,air-matters.io,🍂 Domestic
DOMAIN-SUFFIX,aixifan.com,🍂 Domestic
DOMAIN-SUFFIX,akadns.net,🍂 Domestic
DOMAIN-SUFFIX,alicdn.com,🍂 Domestic
DOMAIN-SUFFIX,alipay.com,🍂 Domestic
DOMAIN-SUFFIX,alipayobjects.com,🍂 Domestic
DOMAIN-SUFFIX,aliyun.com,🍂 Domestic
DOMAIN-SUFFIX,amap.com,🍂 Domestic
DOMAIN-SUFFIX,analytics.126.net,🍂 Domestic
DOMAIN-SUFFIX,apache.org,🍂 Domestic
DOMAIN-SUFFIX,appstore.com,🍂 Domestic
DOMAIN-SUFFIX,autonavi.com,🍂 Domestic
DOMAIN-SUFFIX,bababian.com,🍂 Domestic
DOMAIN-SUFFIX,baidu.com,🍂 Domestic
DOMAIN-SUFFIX,battle.net,🍂 Domestic
DOMAIN-SUFFIX,bdimg.com,🍂 Domestic
DOMAIN-SUFFIX,bdstatic.com,🍂 Domestic
DOMAIN-SUFFIX,beatsbydre.com,🍂 Domestic
DOMAIN-SUFFIX,bilibili.cn,🍂 Domestic
DOMAIN-SUFFIX,bilibili.com,🍂 Domestic
DOMAIN-SUFFIX,bing.com,🍂 Domestic
DOMAIN-SUFFIX,caiyunapp.com,🍂 Domestic
DOMAIN-SUFFIX,ccgslb.com,🍂 Domestic
DOMAIN-SUFFIX,ccgslb.net,🍂 Domestic
DOMAIN-SUFFIX,chinacache.net,🍂 Domestic
DOMAIN-SUFFIX,chunbo.com,🍂 Domestic
DOMAIN-SUFFIX,chunboimg.com,🍂 Domestic
DOMAIN-SUFFIX,clashroyaleapp.com,🍂 Domestic
DOMAIN-SUFFIX,clouddn.com,🍂 Domestic
DOMAIN-SUFFIX,cmfu.com,🍂 Domestic
DOMAIN-SUFFIX,cnbeta.com,🍂 Domestic
DOMAIN-SUFFIX,cnbetacdn.com,🍂 Domestic
DOMAIN-SUFFIX,conoha.jp,🍂 Domestic
DOMAIN-SUFFIX,culturedcode.com,🍂 Domestic
DOMAIN-SUFFIX,didialift.com,🍂 Domestic
DOMAIN-SUFFIX,douban.com,🍂 Domestic
DOMAIN-SUFFIX,doubanio.com,🍂 Domestic
DOMAIN-SUFFIX,douyu.com,🍂 Domestic
DOMAIN-SUFFIX,douyu.tv,🍂 Domestic
DOMAIN-SUFFIX,douyutv.com,🍂 Domestic
DOMAIN-SUFFIX,duokan.com,🍂 Domestic
DOMAIN-SUFFIX,duoshuo.com,🍂 Domestic
DOMAIN-SUFFIX,dytt8.net,🍂 Domestic
DOMAIN-SUFFIX,easou.com,🍂 Domestic
DOMAIN-SUFFIX,ecitic.com,🍂 Domestic
DOMAIN-SUFFIX,ecitic.net,🍂 Domestic
DOMAIN-SUFFIX,eclipse.org,🍂 Domestic
DOMAIN-SUFFIX,eudic.net,🍂 Domestic
DOMAIN-SUFFIX,ewqcxz.com,🍂 Domestic
DOMAIN-SUFFIX,exmail.qq.com,🍂 Domestic
DOMAIN-SUFFIX,feng.com,🍂 Domestic
DOMAIN-SUFFIX,fir.im,🍂 Domestic
DOMAIN-SUFFIX,frdic.com,🍂 Domestic
DOMAIN-SUFFIX,fresh-ideas.cc,🍂 Domestic
DOMAIN-SUFFIX,geetest.com,🍂 Domestic
DOMAIN-SUFFIX,godic.net,🍂 Domestic
DOMAIN-SUFFIX,goodread.com,🍂 Domestic
DOMAIN-SUFFIX,google.cn,🍂 Domestic
DOMAIN-SUFFIX,gtimg.com,🍂 Domestic
DOMAIN-SUFFIX,haibian.com,🍂 Domestic
DOMAIN-SUFFIX,hao123.com,🍂 Domestic
DOMAIN-SUFFIX,haosou.com,🍂 Domestic
DOMAIN-SUFFIX,hdslb.com,🍂 Domestic
DOMAIN-SUFFIX,hdslb.net,🍂 Domestic
DOMAIN-SUFFIX,hollisterco.com,🍂 Domestic
DOMAIN-SUFFIX,hongxiu.com,🍂 Domestic
DOMAIN-SUFFIX,hxcdn.net,🍂 Domestic
DOMAIN-SUFFIX,iciba.com,🍂 Domestic
DOMAIN-SUFFIX,icloud.com,🍂 Domestic
DOMAIN-SUFFIX,ifeng.com,🍂 Domestic
DOMAIN-SUFFIX,ifengimg.com,🍂 Domestic
DOMAIN-SUFFIX,images-amazon.com,🍂 Domestic
DOMAIN-SUFFIX,ipip.net,🍂 Domestic
DOMAIN-SUFFIX,iqiyi.com,🍂 Domestic
DOMAIN-SUFFIX,ithome.com,🍂 Domestic
DOMAIN-SUFFIX,ixdzs.com,🍂 Domestic
DOMAIN-SUFFIX,jd.com,🍂 Domestic
DOMAIN-SUFFIX,jd.hk,🍂 Domestic
DOMAIN-SUFFIX,jianshu.com,🍂 Domestic
DOMAIN-SUFFIX,jianshu.io,🍂 Domestic
DOMAIN-SUFFIX,jianshuapi.com,🍂 Domestic
DOMAIN-SUFFIX,jiathis.com,🍂 Domestic
DOMAIN-SUFFIX,jomodns.com,🍂 Domestic
DOMAIN-SUFFIX,knewone.com,🍂 Domestic
DOMAIN-SUFFIX,kuaidi100.com,🍂 Domestic
DOMAIN-SUFFIX,lecloud.com,🍂 Domestic
DOMAIN-SUFFIX,lemicp.com,🍂 Domestic
DOMAIN-SUFFIX,letv.com,🍂 Domestic
DOMAIN-SUFFIX,letvcloud.com,🍂 Domestic
DOMAIN-SUFFIX,live.com,🍂 Domestic
DOMAIN-SUFFIX,lizhi.io,🍂 Domestic
DOMAIN-SUFFIX,localizecdn.com,🍂 Domestic
DOMAIN-SUFFIX,lucifr.com,🍂 Domestic
DOMAIN-SUFFIX,luoo.net,🍂 Domestic
DOMAIN-SUFFIX,lxdns.com,🍂 Domestic
DOMAIN-SUFFIX,maven.org,🍂 Domestic
DOMAIN-SUFFIX,meizu.com,🍂 Domestic
DOMAIN-SUFFIX,mi.com,🍂 Domestic
DOMAIN-SUFFIX,miaopai.com,🍂 Domestic
DOMAIN-SUFFIX,miui.com,🍂 Domestic
DOMAIN-SUFFIX,miwifi.com,🍂 Domestic
DOMAIN-SUFFIX,mob.com,🍂 Domestic
DOMAIN-SUFFIX,moke.com,🍂 Domestic
DOMAIN-SUFFIX,mxhichina.com,🍂 Domestic
DOMAIN-SUFFIX,myqcloud.com,🍂 Domestic
DOMAIN-SUFFIX,myunlu.com,🍂 Domestic
DOMAIN-SUFFIX,netease.com,🍂 Domestic
DOMAIN-SUFFIX,nssurge.com,🍂 Domestic
DOMAIN-SUFFIX,nuomi.com,🍂 Domestic
DOMAIN-SUFFIX,ourdvs.com,🍂 Domestic
DOMAIN-SUFFIX,outlook.com,🍂 Domestic
DOMAIN-SUFFIX,overcast.fm,🍂 Domestic
DOMAIN-SUFFIX,paypal.com,🍂 Domestic
DOMAIN-SUFFIX,pgyer.com,🍂 Domestic
DOMAIN-SUFFIX,pstatp.com,🍂 Domestic
DOMAIN-SUFFIX,qbox.me,🍂 Domestic
DOMAIN-SUFFIX,qcloud.com,🍂 Domestic
DOMAIN-SUFFIX,qdaily.com,🍂 Domestic
DOMAIN-SUFFIX,qdmm.com,🍂 Domestic
DOMAIN-SUFFIX,qhimg.com,🍂 Domestic
DOMAIN-SUFFIX,qidian.com,🍂 Domestic
DOMAIN-SUFFIX,qihucdn.com,🍂 Domestic
DOMAIN-SUFFIX,qin.io,🍂 Domestic
DOMAIN-SUFFIX,qingmang.me,🍂 Domestic
DOMAIN-SUFFIX,qingmang.mobi,🍂 Domestic
DOMAIN-SUFFIX,qiniucdn.com,🍂 Domestic
DOMAIN-SUFFIX,qiniudn.com,🍂 Domestic
DOMAIN-SUFFIX,qiyi.com,🍂 Domestic
DOMAIN-SUFFIX,qiyipic.com,🍂 Domestic
DOMAIN-SUFFIX,qq.com,🍂 Domestic
DOMAIN-SUFFIX,qqurl.com,🍂 Domestic
DOMAIN-SUFFIX,rarbg.to,🍂 Domestic
DOMAIN-SUFFIX,rrmj.tv,🍂 Domestic
DOMAIN-SUFFIX,ruguoapp.com,🍂 Domestic
DOMAIN-SUFFIX,sandai.net,🍂 Domestic
DOMAIN-SUFFIX,sinaapp.com,🍂 Domestic
DOMAIN-SUFFIX,sinaimg.cn,🍂 Domestic
DOMAIN-SUFFIX,sinaimg.com,🍂 Domestic
DOMAIN-SUFFIX,smzdm.com,🍂 Domestic
DOMAIN-SUFFIX,snwx.com,🍂 Domestic
DOMAIN-SUFFIX,so.com,🍂 Domestic
DOMAIN-SUFFIX,sogou.com,🍂 Domestic
DOMAIN-SUFFIX,sogoucdn.com,🍂 Domestic
DOMAIN-SUFFIX,sohu.com,🍂 Domestic
DOMAIN-SUFFIX,soku.com,🍂 Domestic
DOMAIN-SUFFIX,soso.com,🍂 Domestic
DOMAIN-SUFFIX,speedtest.net,🍂 Domestic
DOMAIN-SUFFIX,sspai.com,🍂 Domestic
DOMAIN-SUFFIX,startssl.com,🍂 Domestic
DOMAIN-SUFFIX,store.steampowered.com,🍂 Domestic
DOMAIN-SUFFIX,suning.com,🍂 Domestic
DOMAIN-SUFFIX,symcd.com,🍂 Domestic
DOMAIN-SUFFIX,taobao.com,🍂 Domestic
DOMAIN-SUFFIX,tenpay.com,🍂 Domestic
DOMAIN-SUFFIX,tietuku.com,🍂 Domestic
DOMAIN-SUFFIX,tmall.com,🍂 Domestic
DOMAIN-SUFFIX,trello.com,🍂 Domestic
DOMAIN-SUFFIX,trellocdn.com,🍂 Domestic
DOMAIN-SUFFIX,ttmeiju.com,🍂 Domestic
DOMAIN-SUFFIX,tudou.com,🍂 Domestic
DOMAIN-SUFFIX,udache.com,🍂 Domestic
DOMAIN-SUFFIX,umengcloud.com,🍂 Domestic
DOMAIN-SUFFIX,upaiyun.com,🍂 Domestic
DOMAIN-SUFFIX,upyun.com,🍂 Domestic
DOMAIN-SUFFIX,uxengine.net,🍂 Domestic
DOMAIN-SUFFIX,v2ex.co,🍂 Domestic
DOMAIN-SUFFIX,v2ex.com,🍂 Domestic
DOMAIN-SUFFIX,vultr.com,🍂 Domestic
DOMAIN-SUFFIX,wandoujia.com,🍂 Domestic
DOMAIN-SUFFIX,weather.com,🍂 Domestic
DOMAIN-SUFFIX,weibo.cn,🍂 Domestic
DOMAIN-SUFFIX,weibo.com,🍂 Domestic
DOMAIN-SUFFIX,weico.cc,🍂 Domestic
DOMAIN-SUFFIX,weiphone.com,🍂 Domestic
DOMAIN-SUFFIX,weiphone.net,🍂 Domestic
DOMAIN-SUFFIX,windowsupdate.com,🍂 Domestic
DOMAIN-SUFFIX,workflowy.com,🍂 Domestic
DOMAIN-SUFFIX,xclient.info,🍂 Domestic
DOMAIN-SUFFIX,xdrig.com,🍂 Domestic
DOMAIN-SUFFIX,xiami.com,🍂 Domestic
DOMAIN-SUFFIX,xiami.net,🍂 Domestic
DOMAIN-SUFFIX,xiaojukeji.com,🍂 Domestic
DOMAIN-SUFFIX,xiaomi.com,🍂 Domestic
DOMAIN-SUFFIX,xiaomi.net,🍂 Domestic
DOMAIN-SUFFIX,xiaomicp.com,🍂 Domestic
DOMAIN-SUFFIX,ximalaya.com,🍂 Domestic
DOMAIN-SUFFIX,xitek.com,🍂 Domestic
DOMAIN-SUFFIX,xmcdn.com,🍂 Domestic
DOMAIN-SUFFIX,xslb.net,🍂 Domestic
DOMAIN-SUFFIX,xunlei.com,🍂 Domestic
DOMAIN-SUFFIX,yach.me,🍂 Domestic
DOMAIN-SUFFIX,yeepay.com,🍂 Domestic
DOMAIN-SUFFIX,yhd.com,🍂 Domestic
DOMAIN-SUFFIX,yinxiang.com,🍂 Domestic
DOMAIN-SUFFIX,yixia.com,🍂 Domestic
DOMAIN-SUFFIX,ykimg.com,🍂 Domestic
DOMAIN-SUFFIX,youdao.com,🍂 Domestic
DOMAIN-SUFFIX,youku.com,🍂 Domestic
DOMAIN-SUFFIX,yunjiasu-cdn.net,🍂 Domestic
DOMAIN-SUFFIX,zealer.com,🍂 Domestic
DOMAIN-SUFFIX,zgslb.net,🍂 Domestic
DOMAIN-SUFFIX,zhihu.com,🍂 Domestic
DOMAIN-SUFFIX,zhimg.com,🍂 Domestic
DOMAIN-SUFFIX,zimuzu.tv,🍂 Domestic

// TeamViewer
IP-CIDR,109.239.140.0/24,🍂 Domestic,no-resolve

DOMAIN-SUFFIX,cn,🍂 Domestic

// Accelerate direct sites
DOMAIN-KEYWORD,torrent,🍂 Domestic

// Force some domains which are fucked by GFW while resolving DNS,or do not respect the system Proxy
DOMAIN-KEYWORD,appledaily,🍃 Proxy,force-remote-dns
DOMAIN-KEYWORD,beetalk,🍃 Proxy,force-remote-dns
DOMAIN-KEYWORD,blogspot,🍃 Proxy,force-remote-dns
DOMAIN-KEYWORD,dropbox,🍃 Proxy,force-remote-dns
DOMAIN-KEYWORD,google,🍃 Proxy,force-remote-dns
DOMAIN-KEYWORD,spotify,🍃 Proxy,force-remote-dns
DOMAIN-KEYWORD,telegram,🍃 Proxy,force-remote-dns
DOMAIN-KEYWORD,whatsapp,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,1e100.net,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,2mdn.net,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,abc.xyz,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,akamai.net,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,appspot.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,autodraw.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,bandwagonhost.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,blogblog.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,cdninstagram.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,chromeexperiments.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,creativelab5.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,crittercism.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,culturalspot.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,dartlang.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,facebook.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,facebook.design,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,facebook.net,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,fb.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,fb.me,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,fbcdn.net,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,fbsbx.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,gcr.io,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,gmail.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,googleapis.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,googlevideo.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,gosetsuden.jp,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,gvt1.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,gwtproject.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,heroku.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,html5rocks.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,humblebundle.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,instagram.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,keyhole.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,kobo.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,kobobooks.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,madewithcode.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,material.io,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,messenger.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,netmarble.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,nianticlabs.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,pinimg.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,pixiv.net,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,pubnub.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,scdn.co,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,t.co,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,telegram.me,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,tensorflow.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,thefacebook.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,toggleable.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,torproject.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,twimg.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,twitpic.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,twitter.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,unfiltered.news,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,waveprotocol.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,webmproject.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,webrtc.org,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,whatsapp.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,whatsapp.net,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,youtube.com,🍃 Proxy,force-remote-dns
DOMAIN-SUFFIX,youtube-nocookie.com,🍃 Proxy,force-remote-dns

// LAN,debugging rules should place above this line
IP-CIDR,10.0.0.0/8,DIRECT
IP-CIDR,100.64.0.0/10,DIRECT
IP-CIDR,127.0.0.0/8,DIRECT
IP-CIDR,172.0.0.0/12,DIRECT
IP-CIDR,192.168.0.0/16,DIRECT

// Detect local network
GEOIP,CN,🍂 Domestic
// Use Proxy for all others
FINAL,🍂 Domestic // 暂无用 ☁️ Others

[Host]
// Host

localhost = 127.0.0.1
syria.sy = 127.0.0.1

thisisinsider.com = server:8.8.4.4

onedrive.live.com = 204.79.197.217
skyapi.onedrive.live.com = 131.253.14.230

[URL Rewrite]
// URL

// Google_Service_HTTPS_Jump
^https?://(www.)?g.cn https://www.google.com 302
^https?://(www.)?google.cn https://www.google.com 302

// Anti_ISP_JD_Hijack
^https?://coupon.m.jd.com/ https://coupon.m.jd.com/ 302
^https?://h5.m.jd.com/ https://h5.m.jd.com/ 302
^https?://item.m.jd.com/ https://item.m.jd.com/ 302
^https?://m.jd.com https://m.jd.com 302
^https?://newcz.m.jd.com/ https://newcz.m.jd.com/ 302
^https?://p.m.jd.com/ https://p.m.jd.com/ 302
^https?://so.m.jd.com/ https://so.m.jd.com/ 302
^https?://union.click.jd.com/jda? http://union.click.jd.com/jda?adblock= header
^https?://union.click.jd.com/sem.php? http://union.click.jd.com/sem.php?adblock= header
^https?://www.jd.com/ https://www.jd.com/ 302

// Anti_ISP_Taobao_Hijack
^https?://m.taobao.com/ https://m.taobao.com/ 302

// Wiki
^https?://.+.(m.)?wikipedia.org/wiki http://www.wikiwand.com/en 302
^https?://zh.(m.)?wikipedia.org/(zh-hans|zh-sg|zh-cn|zh(?=/)) http://www.wikiwand.com/zh 302
^https?://zh.(m.)?wikipedia.org/zh-[a-zA-Z]{2,} http://www.wikiwand.com/zh-hant 302

// Other
^https?://cfg.m.ttkvod.com/mobile/ttk_mobile_1.8.txt http://ogtre5vp0.bkt.clouddn.com/Static/TXT/ttk_mobile_1.8.txt header
^https?://cnzz.com/ http://ogtre5vp0.bkt.clouddn.com/background.png? header
^https?://issuecdn.baidupcs.com/issue/netdisk/guanggao/ http://ogtre5vp0.bkt.clouddn.com/background.png? header
^https?://m.qu.la/stylewap/js/wap.js http://ogtre5vp0.bkt.clouddn.com/qu_la_wap.js 302
^https?://m.yhd.com/1/? http://m.yhd.com/1/?adbock= 302
^https?://n.mark.letv.com/m3u8api/ http://burpsuite.applinzi.com/Interface header
^https?://sqimg.qq.com/ https://sqimg.qq.com/ 302
^https?://static.m.ttkvod.com/static_cahce/index/index.txt http://ogtre5vp0.bkt.clouddn.com/Static/TXT/index.txt header
^https?://www.iqshw.com/d/js/m http://burpsuite.applinzi.com/Interface header
^https?://www.iqshw.com/d/js/m http://rewrite.websocket.site:10/Other/Static/JS/Package.js? header

# URL REJECT

[Header Rewrite]
^*.qpic.cn header-replace User-Agent WeChat/6.5.22.32 CFNetwork/889.9 Darwin/17.2.0
^*.qpic.cn header-del Referer
^*.ph.126.net header-del Referer
^http://www.biquge.com.tw header-del Cookie
^https?://www.zhihu.com/question/ header-del User-Agent

[MITM]
enable = false
hostname = *.qyer.com
ca-passphrase = 6739900C
ca-p12 = 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
EOF
  end
end
