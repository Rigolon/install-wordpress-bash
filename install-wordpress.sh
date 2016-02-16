#!/bin/bash

# Variáveis do Bando de Dados
dbname='';
dbuser='';
dbpass='';

# Usuário e Grupo padrão dos arquivos do Site
userftp='';
groupftp='';

# Link do Wordpress
link="https://br.wordpress.org/";

# Nome do Arquivo
file="latest-pt_BR.zip";

# Caminho completo de Download
wordpress="${link}${file}";

# Pasta que esta sendo utilizada
current_folder="`pwd`/";

# Pasta de plugins
plugins_folder="${current_folder}wp-content/plugins/";

# Caminho da Pasta + Arquivo
full_path_file="${current_folder}/${file}";

# Realiza Download na pasta corrente
/usr/bin/wget $wordpress $current_folder;

# Extrai o conteudo
/usr/bin/unzip ${full_path_file};

# Move os arquivos da pasta wordpress para o direito corrente
/bin/mv ${current_folder}wordpress/* ${current_folder};

# Delete o arquivo baixado
/bin/rm ${full_path_file};

# Deleta a pasta vazia do wordpress
rmdir "${current_folder}/wordpress/";

# Delete o readme.html e license.txt
/bin/rm -f ${current_folder}/readme.html;
/bin/rm -f ${current_folder}/license.txt;
/bin/rm -f ${current_folder}/wp-content/plugins/hello.php;

#Plugins
plugins=(
    contact-form-7
    disable-comments
    duplicate-post
    google-analytics-dashboard-for-wp
    google-sitemap-generator
    ml-slider
    regenerate-thumbnails
    wordfence wordpress-seo
    wp-fastest-cache
);

for i in ${plugins[@]}; do
    plugin="${i}.zip";
    /usr/bin/wget "https://downloads.wordpress.org/plugin/${plugin}" -O ${plugins_folder}${plugin};
    /usr/bin/unzip ${plugins_folder}$plugin -d ${plugins_folder};
    /bin/rm -f ${plugins_folder}$plugin;
done

# Gera o arquivo de configuracao do WordPress
/bin/cp "${current_folder}wp-config-sample.php" "${current_folder}wp-config.php";

# Configura as senhas no arquivo
/usr/bin/perl -pi -e "s/nome_do_banco_de_dados/${dbname}/g" "${current_folder}wp-config.php";
/usr/bin/perl -pi -e "s/nome_de_usuario_aqui/${dbuser}/g" "${current_folder}wp-config.php";
/usr/bin/perl -pi -e "s/senha_aqui/${dbpass}/g" "${current_folder}wp-config.php";

# Configura o SALT
/usr/bin/perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/altere cada chave para um frase única/salt()/ge
' "${current_folder}wp-config.php";

# Cria a pasta de uploads e da permissão
/bin/mkdir "${current_folder}wp-content/uploads";
/bin/chmod 775 "${current_folder}wp-content/uploads";

# Da permissao correta nos arquivos
chown -R ${userftp}:${groupftp} ${current_folder};
/usr/bin/find ${current_folder} -type d -exec /bin/chmod 755 {} +
/usr/bin/find ${current_folder} -type f -exec /bin/chmod 644 {} +
