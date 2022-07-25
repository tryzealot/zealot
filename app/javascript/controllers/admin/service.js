function restarting() {
  try {
    fetch(window.HOST + "admin/service/restart", {
      method: "POST"
    });

    return true;
  } catch (error) {
    return false;
  }
}

function isOnline() {
  try {
    fetch(window.HOST + "admin/service/status", {
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
  var orinalText = $(button).html();

  var restartingText = $(button).data("restart-text");
  var restartedText = $(button).data("restarted-text");
  $(button).html("<i class='fas fa-spin fa-sync'></i>" + restartingText);
  var serverRestarting = true;

  var restart_success = await restarting();
  console.debug(restart_success ? 'success' : 'fail');
  await sleep(2000);
  if (!restart_success) {
    console.error('Error restarted');
    $(button).html(orinalText);
    return false;
  }

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
