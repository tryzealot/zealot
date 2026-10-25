import { application } from "./application"

import DrawerController from "./drawer_controller"
application.register("drawer", DrawerController)

import ThemeController from "./theme_controller"
application.register("theme", ThemeController)

import ClipboardCenterController from "./clipboard_center_controller"
application.register("clipboard-center", ClipboardCenterController)

import installLimitedController from "./install_limited_controller"
application.register("install-limited", installLimitedController)

import ReleaseDownloadController from "./release_download_controller"
application.register("release-download", ReleaseDownloadController)

import UDIDController from "./udid_controller"
application.register("udid", UDIDController)

import BulkOperationController from "./bulk_operation_controller"
application.register("bulk-operation", BulkOperationController)

import ModalController from "./modal_controller"
application.register("modal", ModalController)

import SwapIconController from "./swap_icon_controller"
application.register("swap-icon", SwapIconController)

import TabSwitchController from "./tab_switch_controller"
application.register("tab-switch", TabSwitchController)

import BreadcrumbsController from "./breadcrumbs_controller"
application.register("breadcrumbs", BreadcrumbsController)

import "./admin"
