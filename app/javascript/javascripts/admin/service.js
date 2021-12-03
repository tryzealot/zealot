function restarting() {
  fetch("/admin/service/restart", {
    method: "POST"
  });
}

function isOnline() {
  try {
    fetch("/admin/service/status", {
      method: "GET"
    });
    return true;
  } catch (error) {
    return false;
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function restartService(button) {
  $("#notifications").fadeOut();

  var restartingText = $(button).data("restart-text");
  var restartedText = $(button).data("restarted-text");
  $(button).html("<i class='fas fa-spin fa-sync'></i>" + restartingText);
  var serverRestarting = true;

  await restarting();
  await sleep(2000);

  do {
    var online = await isOnline();
    if (online) {
      serverRestarting = false;
    } else {
      await sleep(1000);
    }
  } while (serverRestarting);

  $(button).removeClass("bg-warning")
    .addClass("bg-success")
    .html("<i class='fas fa-spin fa-sync'></i>" + restartedText);

  await sleep(2000);
  window.location.reload();
}
