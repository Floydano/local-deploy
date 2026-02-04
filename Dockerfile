FROM wordpress:php8.2-fpm

# ---------------------------------------------------------
# 1. Instalar Nginx y utilidades
# ---------------------------------------------------------
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    curl \
    unzip \
    vim \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# 2. Configurar Nginx
# ---------------------------------------------------------
COPY k8s/nginx.conf /etc/nginx/nginx.conf
COPY k8s/site.conf /etc/nginx/sites-available/default

# ---------------------------------------------------------
# 3. Configurar PHP (opcional)
# ---------------------------------------------------------
COPY k8s/php.ini /usr/local/etc/php/conf.d/custom.ini

# ---------------------------------------------------------
# 4. Configurar supervisord para ejecutar Nginx + PHP-FPM
# ---------------------------------------------------------
COPY k8s/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ---------------------------------------------------------
# 5. Copiar plugins personalizados
# ---------------------------------------------------------
#COPY plugins/* /var/www/html/wp-content/plugins/

# ---------------------------------------------------------
# 6. Copiar temas personalizados
# ---------------------------------------------------------
#COPY themes/* /var/www/html/wp-content/themes/

# ---------------------------------------------------------
# 7. Copiar archivos custom del sitio
# ---------------------------------------------------------
#COPY custom/* /var/www/html/wp-content/

# ---------------------------------------------------------
# 8. Ajustar permisos
# ---------------------------------------------------------
RUN chown -R www-data:www-data /var/www/html

# ---------------------------------------------------------
# 9. Exponer puertos
# ---------------------------------------------------------
EXPOSE 80

# ---------------------------------------------------------
# 10. Iniciar supervisord (Nginx + PHP-FPM)
# ---------------------------------------------------------
CMD ["/usr/bin/supervisord", "-n"]
