/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

domains_to_allow = ["federicobusetti.com"]

billing_data_users = "gcp-billing-admins@federicobusetti.com"

audit_data_users = "gcp-security-admins@federicobusetti.com"

org_id = "92694335260"

billing_account = "01D068-2DC165-FC6683"

terraform_service_account = "org-terraform@cft-seed-95d6.iam.gserviceaccount.com"

default_region = "europe-west2"

scc_notification_name = "scc-notify"

//Optional - for development.  Will place all resources under a specific folder instead of org root
//parent_folder = "01234567890"
//scc_notification_filter = "state=\\\"ACTIVE\\\""
//create_access_context_manager_access_policy = false
