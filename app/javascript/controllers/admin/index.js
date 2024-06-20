import { application } from "../application"

import NewReleaseController from "./new_release_controller"
application.register("admin-new-release", NewReleaseController)

import ServiceController from "./service_controller"
application.register("admin-service", ServiceController)

import SMTPVerifyController from "./smtp_verify_controller"
application.register("admin-smtp-verify", SMTPVerifyController)

import LogsController from "./logs_controller"
application.register("admin-logs", LogsController)

import CronController from "./cron_controller"
application.register("admin-cron", CronController)
