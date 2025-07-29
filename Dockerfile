FROM httpd:2.4
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./exam/. /usr/local/apache2/htdocs/
CMD ["httpd-foreground"]

