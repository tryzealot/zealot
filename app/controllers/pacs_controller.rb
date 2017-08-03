class PacsController < ApplicationController
  before_action :authenticate_user!, only: [ :index, :new, :create, :edit, :update, :destroy]
  before_action :set_pac, only: [:show, :edit, :update, :destroy]

  # GET /pacs
  def index
    @title = '自动代理列表'
    @pacs = Pac.all
  end

  # GET /pacs/1
  # GET /pacs/1.pac
  def show
    @title = @pac.title
    respond_to do |format|
      format.pac { render :show, status: :ok, location: @pac }
      format.html { render :show, status: :ok, location: @pac }
    end
  end

  # GET /pacs/new
  def new
    @title = '新建自动代理'
    @pac = Pac.new
    default_script
  end

  def edit
    @title = '编辑自动代理'
    default_script
  end

  # POST /pacs/create
  def create
    @pac = Pac.new(pac_params)

    respond_to do |format|
      if @pac.valid?(:web) && @pac.save
        format.html { redirect_to @pac, notice: 'pac was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /pacs/1
  # PATCH/PUT /pacs/1.pac
  def update
    respond_to do |format|
      if @pac.update(pac_params)
        format.html { redirect_to @pac, notice: 'pac was successfully updated.' }
        format.json { render :show, status: :ok, location: @pac }
      else
        format.html { render :edit }
        format.json { render json: @pac.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pacs/1
  # DELETE /pacs/1.pac
  def destroy
    @pac.destroy
    respond_to do |format|
      format.html { redirect_to pacs_url, notice: 'pac was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected

  def js_request?
    request.format.js?
  end

  def set_pac
    @pac = Pac.find(params[:id])
    default_script
  end

  def default_script
    @default_script = <<-PAC
function FindProxyForURL(url, host) {
    // 匹配单个域名走多个代理，第一个失败后将会尝试后面的代理
    // if (dnsDomainIs(host, "open.qyer.com")
    //     return "PROXY 172.1.30.123:8080; PROXY 7.8.9.10:8080";

    // 使用通配符匹配域名，先走代理，失败后直连网络
    // if (shExpMatch(host, "*.qyer.com"))
    //     return "PROXY 172.1.30.123:8080; DIRECT";

    // 如果使用 `qma pac` 上报本机 IP 和端口号，可用如下变量：
    // @host - IP 地址
    // @port - 端口号
    // if (shExpMatch(host, "*.qyer.com"))
    //     return "PROXY @host:@port; PROXY 172.1.30.123:8080; DIRECT";

    // 默认规则：其他所有流量直连网络
    return "DIRECT";
}
PAC
  end

  def pac_params
    params.require(:pac).permit(:title, :script)
  end
end
