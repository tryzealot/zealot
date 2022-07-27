import clipboard from "clipboard"
window.ClipboardJS = clipboard

function clearTooltip(e) {
  $(e).tooltip("hide");
  $(e).tooltip("disable");
}

function showTooltip(e, msg) {
  $(e).attr("title", msg);
  $(e).tooltip("enable");
  $(e).tooltip("show");
}

function fallbackMessage(action) {
  var actionMsg = "";
  var actionKey = (action === "cut" ? "X" : "C");
  if (/iPhone|iPad/i.test(navigator.userAgent)) {
    actionMsg = "无法复制到剪切板 :(";
  } else if (/Mac/i.test(navigator.userAgent)) {
    actionMsg = "按 ⌘-" + actionKey + " 复制文本";
  } else {
    actionMsg = "按 Ctrl-" + actionKey + " 复制文本";
  }
  return actionMsg;
}

$(document).on("turbo:load", function () {
  var clipboardButton = ".btn-clipboard";
  $(clipboardButton).on("mouseleave", function () {
    clearTooltip(this);
  });

  var clipboard = new ClipboardJS(clipboardButton);
  clipboard.on("success", function (e) {
    e.clearSelection();

    showTooltip(e.trigger, "已复制到剪切板");
  });

  clipboard.on("error", function (e) {
    showTooltip(e.trigger, fallbackMessage(e.action));
  });
});