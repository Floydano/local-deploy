FROM wordpress:latest

# Configuración básica: expone el puerto 80 para WordPress
EXPOSE 80

# Comando por defecto para ejecutar Apache
CMD ["apache2-foreground"]
