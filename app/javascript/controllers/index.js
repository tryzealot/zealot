import { application } from "./application"

import GlobalController from "./global_controller"
application.register("global", GlobalController)

import BetterErrorsController from "./better_errors_controller"
application.register("better-errors", BetterErrorsController)

import ClipboardCenterController from "./clipboard_center_controller"
application.register("clipboard-center", ClipboardCenterController)

import ReleaseDownloadController from "./release_download_controller"
application.register("release-download", ReleaseDownloadController)

import DestroyController from "./destroy_controller"
application.register("destroy", DestroyController)

import UDIDController from "./udid_controller"
application.register("udid", UDIDController)

import "./admin"
