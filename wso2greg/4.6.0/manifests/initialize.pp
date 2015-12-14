#----------------------------------------------------------------------------
#  Copyright 2005-2015 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------

define registry::initialize ($repo, $version, $service, $local_dir, $target, $mode, $owner,) {
  exec {
    "creating_target_for_${name}":
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      command => "mkdir -p ${target}",
      unless  => "test -d ${target}";

    "creating_local_package_repo_for_${name}":
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
      unless  => "test -d ${local_dir}",
      command => "mkdir -p ${local_dir}";

    "downloading_${service}-${version}.zip_for_${name}":
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd       => $local_dir,
      unless    => "test -f ${local_dir}/${service}-${version}.zip",
      command   => "wget -q ${repo}/${service}-${version}.zip",
      logoutput => 'on_failure',
      creates   => "${local_dir}/${service}-${version}.zip",
      timeout   => 0,
      require   => Exec["creating_local_package_repo_for_${name}", "creating_target_for_${name}"];

    "extracting_${service}-${version}.zip_for_${name}":
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd       => $target,
      unless    => "test -d ${target}/${service}-${version}/repository",
      command   => "unzip ${local_dir}/${service}-${version}.zip",
      logoutput => 'on_failure',
      creates   => "${target}/${service}-${version}/repository",
      timeout   => 0,
      notify    => Exec["setting_permission_for_${name}"],
      require   => Exec["downloading_${service}-${version}.zip_for_${name}"];

    "setting_permission_for_${name}":
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd         => $target,
      command     => "chown -R ${owner}:${owner} ${target}/${service}-${version} ;
                      chmod -R 755 ${target}/${service}-${version}",
      logoutput   => 'on_failure',
      timeout     => 0,
      refreshonly => true,
      require     => Exec["extracting_${service}-${version}.zip_for_${name}"];
  }
}