defineClass("QYBBSDetailViewController", {
  setupUI: function() {
    // self.super().viewWillAppear();

    var alertView = require('UIAlertView').alloc().init();
    alertView.setTitle('重载方法');
    alertView.setMessage('重载 viewDidiLoad');
    alertView.addButtonWithTitle('OK');
    alertView.show();
  }
})