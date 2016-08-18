FROM nginx

RUN apt-get update && apt-get install -y curl git wget

#install ruby
RUN rm /bin/sh && ln -s /bin/bash /bin/sh # allows for source
RUN gpg --keyserver hkp://keys.gnupg.net:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -L https://get.rvm.io | bash -s stable --ruby && \
    source /usr/local/rvm/scripts/rvm

RUN /usr/local/rvm/scripts/rvm install ruby && \
    /usr/local/rvm/scripts/rvm use 2.2.1 --default 


#install ruby gems
# hmm seems to need a bash shell otherwise rvm won't be found oh well
RUN  /bin/bash -c "source /usr/local/rvm/scripts/rvm && \
     pushd /tmp && \
     wget https://rubygems.org/rubygems/rubygems-2.6.2.tgz && \
     tar -xzvf rubygems-2.6.2.tgz && \
     cd rubygems-2.6.2 && \
     ruby setup.rb && \
     popd"

#install jekyll
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && \
    gem install jekyll && \
    gem install jekyll-textile-converter"
    
    #    apt-get install -y ruby-full git emacs && \

COPY . /tmp/godiego-org-files

# make static files
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && \
    pushd /tmp/godiego-org-files/jekyll_content && \ 
    jekyll build"

# put static files in the right place
RUN mkdir -p /var/www/godiego.org
RUN cp -r /tmp/godiego-org-files/jekyll_content/_site/* /var/www/godiego.org

# copy over static file configurations in right place
RUN cp /tmp/godiego-org-files/nginx/godiego.org.conf /etc/nginx/conf.d/
RUN cp /tmp/godiego-org-files/nginx/nginx.conf /etc/nginx/



#TODO: separate static files from rest of repo, so that they don't get combined up with conf files
