Explaining the different files in the directory

apache2.conf  
   Lives in /etc/apache2. Added option to load the webauth module in Apache. Lines 238 to 242 in file

krb5.conf  
  This file site in /etc/. It has settings for kerberos principle

webauth.conf  
  The config file for the webauth module. It is in /etc/apache2/mods-enabled/webauth.conf

hydra  
   Example apache site config with options to reverse proxy to port 80 when running rails server in port 3000 in dev

hydra-apache  
  Example apache site config to work with apache and passenger

hydra-apache-ssl  
  Example apache site config to with apache and passenger and has ssl certificates installed and mod ssl enabled

hydra-webauth-ssl  
  Apache site config used in development, which is working with apache, passenger, webauth (and devise-remote-user) and ssl

oradeposit-dev.conf  
  Apache site config used in qa, also working with  apache, passenger, webauth (and devise-remote-user) and ssl

