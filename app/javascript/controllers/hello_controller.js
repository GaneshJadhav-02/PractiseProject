/**
 * Copyright © 2025 OwnersTable Inc. All rights reserved.
 * This source code is proprietary and confidential.
 * Unauthorized copying or distribution is strictly prohibited.
 */

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
