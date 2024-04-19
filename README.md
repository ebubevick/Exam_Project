## Execution Overview

This document outlines the updated steps and processes involved in deploying a PHP Laravel application using a bash script and an Ansible playbook. The deployment process now includes verifying the accessibility of the PHP application and creating a cron job to check server uptime.

### Ansible Playbook: Execute bash script, verify PHP application accessibility, and monitor server uptime

#### Purpose:
The updated Ansible playbook orchestrates the deployment process, verifies the accessibility of the PHP application, and sets up a cron job to monitor server uptime.

#### Tasks:
1. **Copy Bash Script**: Copies the bash script `lamp_laravel_deployment.sh` to the target node.
2. **Execute Bash Script**: Executes the copied bash script on the target node, deploying the PHP Laravel application.
3. **Display PHP Application Content using Curl**: Retrieves the content of the PHP application using curl and registers the output.
4. **Display PHP Application Content**: Displays the content of the PHP application if accessible.
5. **Display Message if PHP Application is Accessible**: Displays a message confirming the accessibility of the PHP application if the curl command returns a successful exit code.
6. **Create Cron Job to Check Server Uptime**: Sets up a cron job to run the `uptime` command daily at midnight.
7. **Display Server Uptime**: Retrieves and registers the server uptime.
8. **Print Server Uptime**: Displays the server uptime.

### Updated Usage
1. Ensure that Ansible is installed on the control node and SSH access is configured to the target node.
2. Place the bash script (`lamp_laravel_deployment.sh`) and the updated Ansible playbook in the appropriate directories.
3. Update the playbook to reflect the correct paths for the bash script and target node.
4. Execute the playbook using the `ansible-playbook` command.
5. Monitor the deployment process, verify the accessibility of the PHP application, and check the server uptime using the created cron job.

This documentation provides an updated guide for deploying a PHP Laravel application using automation tools like Ansible and a custom bash script. By following these steps, you can efficiently deploy your PHP application, verify its accessibility, and monitor server uptime.
