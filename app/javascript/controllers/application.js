/**
 * Copyright © 2025 OwnersTable Inc. All rights reserved.
 * This source code is proprietary and confidential.
 * Unauthorized copying or distribution is strictly prohibited.
 */

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
