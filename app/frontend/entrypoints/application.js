import "@hotwired/turbo-rails"
import "../stylesheets/application.css"
import "../controllers"
import { installStaleStreamGuard } from "../streams/stale_stream_guard"

installStaleStreamGuard()
