import { application } from "../application"

import NewReleaseController from "./new_release_controller"
application.register("admin-new-release", NewReleaseController)

import ServiceController from "./service_controller"
application.register("admin-service", ServiceController)

import LogsController from "./logs_controller"
application.register("admin-logs", LogsController)