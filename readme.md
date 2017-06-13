Verkbox
--------
Verkbox is a template for using VirtualBox and Vagrant to create a work environment
for development. The environment will mirror the production environment of choice.
In the `virtualbox-ubuntu` template, it will use Ubuntu-16.04. Edit the `Vagrantfile` to select a different OS and different settings.

To customize, edit the `bootstrap_ubuntu.sh` file, by uncommenting the install functions
in the MAIN section for the software you like to provision. The functions are found in the `lib_fn.sh` file. Edit the `cfg.json` for
your own project settings.

Install And Run
-------
* Install VirtualBox (https://www.virtualbox.org/wiki/Downloads)
* Install Vagrant (https://www.vagrantup.com/downloads.html)
* Edit the `Vagrantfile`, `cfg.json` and `bootstrap_ubuntu.sh` to your needs.
* Run `vagrant up` to run the instance, on first time it will also perform a `vagrant provision` automatically
* Run `vagrant ssh` to ssh to the instance
* `exit` will return you to the host
* `vagrant halt` will shutdown the instance


Vagrant Commands
--------
```
vagrant up
vagrant box list
vagrant box add {title} {url}
vagrant init {title}
vagrant provision
vagrant suspend | halt | destroy
vagrant reload
vagrant ssh
```
