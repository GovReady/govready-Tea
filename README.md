GovReady-TEA
=============================

# Status

| Date         | Status | Time to Build |
|--------------|-------------|-------------|
| Mar 14, 2014 Updated| VM OK. Install Tea OK. No SCAP. | real 41m9.848s; user 0m14.815s; sys 0m11.125s |

A GovReady GitMachine for TEA

## Goals

Make it easier to distribute and use Ben Klemens TEA data survey tool

ben.klemens@census.gov


## Background

Survey data does not arrive in good condition. It needs a number of post-processing steps to be useful:

* Editing: the person who said she's 314 years old and makes $22/year needs to be edited, or else all your statistics will be skewed.

* Disclosure avoidance: we want to protect the privacy of respondents, and so can not release all responses. What is the least that needs to be obscured to achieve at least reasonable privacy?

* Imputing: not everybody responded to every question, and the blanks should be imputed by the people administering the survey. Leaving survey users to fill in the blanks will create bias because most users have no idea how to avoid imputation bias, create worse imputations because the user has post-disclosure-avoidance data, and put up barriers for users with limited skills who may not know what to do with NA markers.

We designed a system, Tea, to put survey post-processing in one place. The hope is that you come in with pre-processed data, write a single spec file and a single control file describing the processing you want done, and come away with output ready for release. It is used for one detail of processing of the 2010 Census (and its occasional revisions), and a small part of the American Community Survey, but we designed it to have much broader applicability.

I've attached a copy of a paper I presented at a UN Commission, which you can skim to get a better idea of the system.

## Manual Installation Instructions (from Ben)

Installation issues:
-------------------

Tea is an R package with a C back-end.

I have always leaned toward building upon previous work rather than reinventing wheels in whatever language is popular this week, though this can lead to a lot of dependencies for one project. Further, R's CRAN makes it difficult to distribute an R package that depends on C libraries.

Here are the dependencies:

--Apophenia, a library of statistical models [ http://apophenia.info ]. It's in standard C. It builds upon SQLite3 and the GNU Scientific Library, both of which are commonly available. Apophenia isn't available via any package managers I know of, but is Autoconf'ed and installs with a simple ./configure && make && make install if the SQLite and GSL headers are in place.


--We wrote an R-front end for Apophenia named Rapophenia. [ https://r-forge.r-project.org/projects/rapophenia/ ] I think it only depends on Apophenia.

--Tea [ https://r-forge.r-project.org/projects/tea/ ] itself depends on a large number of R packages (which then depend on other R pkgs).


--Apophenia works with mySQL/mariadb as well; we'd like to set Tea up to work with mySQL too, but haven't been able to convince Census IT to activate a mySQL server for us.


## The script:

In theory, this script should download all the required parts after the prerequisite GSL and SQLite development and R pkgs are already in place.


I don't have root, so set up a local root directory with ~/root/lib, ~/root/bin, ...

### Configure environment

```
echo "
export PATH=$HOME/root/bin/:$PATH
export LD_LIBRARY_PATH=$HOME/root/lib/:$LD_LIBRARY_PATH
export LIBRARY_PATH=$HOME/root/lib/:$LIBRARY_PATH
export C_INCLUDE_PATH=$HOME/root/include/:$C_INCLUDE_PATH
export CPATH=$HOME/root/include/:$CPATH" >> ~/.bashrc
source ~/.bashrc

mkdir ~/root
```

### Install Apophenia

Here's a tgzed copy of Apophenia from my vanity domain, because Sourceforge is blocked by the Census bureau. Uses Autoconf.
Prerequisites: libgsl-devel, sqlite3-devel pkgs

```
wget http://klemens.org/asst/apop.tgz
tar xvzf apop.tgz
cd apopheni*
./configure --prefix /home/bk/root
make
make install
```

### Get the requisite R packages.

```
mkdir ~/root/share/rlibs -p
echo "R_LIBS=$HOME/root/share/rlibs" > ~/.Renviron
R -e 'install.packages(c("gam", "ggplot2", "RSQLite", "multicore", "MCMCpack", "gdata", "tree", "testthat"), lib="~/root/share/rlibs", repos="http://cran.fhcrc.org")'
```

### Install Rapophenia

Also from my vanity domain, because you need svn to pull from R-forge. I think you could get this from Github now.

```
wget http://klemens.org/asst/rapop.tgz
tar xvzf rapop.tgz
cd Rapop*
R CMD INSTALL -l ~/root/share/rlibs .
cd ..
```


### Finally, get Tea

```
wget http://klemens.org/asst/tea.tgz
tar xvzf tea.tgz
cd tea
R CMD build .
R CMD INSTALL -l ~/root/share/rlibs .
```

### Test

May produce warnings (use warnings() to see them), but should exit OK.

```
cd tests
R -f C_tests.R

cd ../..
```

## Links

### Ansible
* [Jeff Geerling Slides](http://www.slideshare.net/geerlingguy/local-development-on-virtual-machines-vagrant-virtualbox-and-ansible)
* [Ansible's Example on GitHub](https://github.com/ansible/ansible-examples/tree/master/lamp_simple)
* [Julian Ponge post with examples](http://julien.ponge.org/blog/scalable-and-understandable-provisioning-with-ansible-and-vagrant/)
* [Ansible docs on using Vagrant](http://docs.ansible.com/guide_vagrant.html)
* [Vagrant docs on using Ansible](http://docs.vagrantup.com/v2/provisioning/ansible.html)
* [Getting Cirrius example of Ansible and Firewall rules](http://www.gettingcirrius.com/2013/11/configure-iptables-with-ansible.html)
* [CentOS wiki EC2 and Ansible](http://wiki.centos.org/Cloud/Manage/Ansible)

More on Ansible
* Ansible executes in order.
* Ansible playbook needs to address `hosts`, `vars`, `handlers`, and `tasks`. 
* Variable substitution in Ansible `{{ var_name }}` 
* Ansible loop you indicate the command and then add `with_items` YAML list. 
* Ansible copy file by defaults copies `src` from Ansible computer to `dest` on guest (target) server. You can set mode and ownership
* Copying files really is an easy way manage firewalls and vhost configurations.


