import { Controller } from "@hotwired/stimulus"
import JQuery from "jquery"

const LOADING_TIMEOUT = 8000

export default class extends Controller {
  static targets = [ "downloadButton", "installIssue" ]
  static values = {
    installing: String,
    installed: String,
    installUrl: String
  }

  download() {
    this.renderLoading()

    const link = this.installUrlValue
    console.log('install url: '+ link)
    window.location.href = link
  }

  showQA() {
    JQuery('#install-issues').modal('toggle')
  }

  build() {
    // jquery version legacy
    // var button = $('#build_it');
    // button.button('loading');

    // var app_job = button.data('job');
    // var url = HOST + "api/v2/jenkins/projects/" + app_job + "/build";
    // console.log('build url: ', url);

    // $.ajax({
    //   url: url,
    //   type: 'get',
    //   dataType: 'json',
    //   success: function (data) {
    //     console.log(data)
    //     if (data.code == 201 || data.code == 200) {
    //       var url = data.url + 'console';
    //       message = '请求成功！访问这里查看详情：<a href="' + url + '">' + url + '</a>';
    //     } else {
    //       message = '错误：' + data.message;
    //     }

    //     if (data.code == 201) {
    //       sleep(8000);
    //     }

    //     $('#jekins_buld_alert').removeClass('hidden').html(message);
    //   },
    //   error: function (xhr, ajaxOptions, thrownError) {
    //     button.button('reset');
    //     //  $('#cache-info').data('key', xhr.responseJSON.cache).removeClass('hide')
    //     //  $("#result")
    //     //      .html('请求失败！接口返回：' + xhr.responseJSON.message)
    //     //      .addClass("alert alert-danger")
    //     //      .show()
    //   },
    //   complete: function () {
    //     button.button('reset');
    //   }
    // });
  }

  async renderLoading() {
    this.downloadButtonTarget.innerHTML = this.installingValue
    await this.sleep(LOADING_TIMEOUT)
    this.downloadButtonTarget.innerHTML = this.installedValue
    this.installIssueTarget.classList.remove("d-none")
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}