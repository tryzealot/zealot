import consumer from "./consumer"

const notificationChannel = consumer.subscriptions.create("NotificationChannel", {
  received(data) {
    var color = 'success';
    var icon = 'fas fa-check';
    if (data.status != 'success') {
      icon = 'fas fa-exclamation-triangle';
      color = 'danger';
    }

    $("#notifications").prepend(
      '<div class="alert alert-dismissible alert-' + color + '">' +
      '<button aria-hidden="true" class="close" data-dismiss="alert">×</button>' +
      '<h4><i class="icon fas fa-' + icon + '"></i>' +
      '<span id="flash_notice">' + data.message + '</span></h4 ></div >'
    );

    if (data.refresh_page) {
      setTimeout(() => {
        location.reload();
      }, 3000);
    }
  }
});

export default notificationChannel;