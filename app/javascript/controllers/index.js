import { application } from "./application"

import GlobalController from "./global_controller"
application.register("global", GlobalController)

import ClipboardCenterController from "./clipboard_center_controller"
application.register("clipboard-center", ClipboardCenterController)

import installLimitedController from "./install_limited_controller"
application.register("install-limited", installLimitedController)

import ReleaseDownloadController from "./release_download_controller"
application.register("release-download", ReleaseDownloadController)

import DestroyController from "./destroy_controller"
application.register("destroy", DestroyController)

import UDIDController from "./udid_controller"
application.register("udid", UDIDController)

import BulkOperationController from "./bulk_operation_controller"
application.register("bulk-operation", BulkOperationController)

import ModalController from "./modal_controller"
application.register("modal", ModalController)

import "./admin"
