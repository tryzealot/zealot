import * as ActionCable from "@rails/actioncable"
import { Zealot } from "../controllers/zealot"

if (Zealot.isDevelopment) {
  ActionCable.logger.enabled = true
}
