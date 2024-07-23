import { Controller } from "@hotwired/stimulus"
import jquery from "jquery"
import { isiOS, isMacOS } from "./utils"

const LOADING_TIMEOUT = 8000

export default class extends Controller {
  static targets = [
    "installLimited",
    "buttons",

    "installButton",
    "downloadButton",

    "installIssue",
    "certExpired"
  ]

  static values = {
    installLimited: Array,
    openSafari: String,
    openBrower: String,

    installUrl: String,
    installing: String,
    installed: String
  }

  connect() {
    if (this.isInstallLimited()) {
      return this.renderInstallLimited()
    }

    if (isiOS()) {
      this.showIntallButton()
      this.hideDownloadButton()
    } else if (isMacOS()) {
      this.showIntallButton()
    }
  }

  install(event) {
    this.renderLoading(event.target)

    const link = this.installUrlValue
    console.debug("install url", link)
    window.location.href = link
  }

  showCertExpired() {
    jquery("#cert-expired-issues").modal("toggle")
  }

  showQA() {
    jquery("#install-issues").modal("toggle")
  }

  build() {
    // jquery version legacy
    // var button = $("#build_it");
    // button.button("loading");

    // var app_job = button.data("job");
    // var url = HOST + "api/v2/jenkins/projects/" + app_job + "/build";
    // console.log("build url: ", url);

    // $.ajax({
    //   url: url,
    //   type: "get",
    //   dataType: "json",
    //   success: function (data) {
    //     console.log(data)
    //     if (data.code == 201 || data.code == 200) {
    //       var url = data.url + "console";
    //       message = "请求成功！访问这里查看详情：<a href="' + url + '">" + url + "</a>";
    //     } else {
    //       message = "错误：" + data.message;
    //     }

    //     if (data.code == 201) {
    //       sleep(8000);
    //     }

    //     $("#jekins_buld_alert").removeClass("hidden").html(message);
    //   },
    //   error: function (xhr, ajaxOptions, thrownError) {
    //     button.button("reset");
    //     //  $("#cache-info").data("key", xhr.responseJSON.cache).removeClass("hide")
    //     //  $("#result")
    //     //      .html("请求失败！接口返回：" + xhr.responseJSON.message)
    //     //      .addClass("alert alert-danger")
    //     //      .show()
    //   },
    //   complete: function () {
    //     button.button("reset");
    //   }
    // });
  }

  async renderLoading(target) {
    target.innerHTML = this.installingValue
    await this.sleep(LOADING_TIMEOUT)
    target.innerHTML = this.installedValue
    this.installIssueTarget.classList.remove("d-none")
  }

  showIntallButton() {
    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.classList.remove("d-none")
    }
  }

  hideDownloadButton() {
    if (this.hasDownloadButtonTarget) {
      this.downloadButtonTarget.classList.add("d-none")
    }
  }

  renderInstallLimited() {
    let textNode = this.installLimitedTarget.getElementsByClassName("text")[0]
    let brNode = document.createElement("br")
    textNode.appendChild(brNode)
    if (isiOS()) {
      textNode.appendChild(document.createTextNode(this.openSafariValue))
    } else {
      textNode.appendChild(document.createTextNode(this.openBrowerValue))
    }

    this.installLimitedTarget.classList.remove("d-none")
    this.buttonsTarget.classList.add("d-none")
  }

  isInstallLimited() {
    let ua = navigator.userAgent
    let matches = this.installLimitedValue.find(keyword => ua.includes(keyword))

    return !!matches
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
}
