FROM afcai2c/python38-ai:latest AS multi-stage
FROM afcai2c/jupyterlab:latest

COPY --from=multi-stage /opt/python /opt/python

# Makes the python packages accessable
ENV PATH="/opt/python/venv/bin:$PATH"

USER root

#Workaround for perl issue preventing yum upgrade
RUN dnf remove -y perl-threads

RUN dnf upgrade -y     && \
    dnf clean all -y   && \
    dnf install -y        \
        vim               \
        zip               \
        unzip             \
        net-tools         \
        # gcc is needed for prophet
        gcc-c++           \
        git

# Needed to use packges from multi-stage build in Jupyterlab
RUN python3.8 -m pip install ipykernel

RUN python3.8 -m pip install --upgrade pip

RUN python3.8 -m pip install    \
        wheel                   \
        pbr                     \
        tensorflow              \ 
        ds2                     \
        torch                   \
        Keras                   \
        fastai                  \
        cudnnenv                \
        gluon	 		        \
		jupyterlab		        \
   		jupyterlab-git	 		\
      	matplotlib	 		\
   		geopandas	 		\
   		geojson	 			\
   		pysal	 			\
   		mapclassify	 		\
      	osmnx	 			\
  		geopy	 			\
   		geojson	 			\
      	rasterio	 	        \	
      	contextily	 	        \
      	folium	 			\
   		mplleaflet	                \
		bokeh				\
		sphinx				 \	
		recommonmark		        \
		pytest			        \
		numpydoc		        \
		h5py			        \
		xmltodict		        \
		tqdm			      	\
		numpy		           	\
		pillow	                  	\
      	sphinx_rtd_theme	        \
		open-cv-plus			\
		pandas			        \
		twine		               	\
		rtree		               	\
		rasterio	               	\
		psutil		               	\
		torchvision     	        \
		slidingwindow			\
		bumpversion		       	\
      	sphinx-markdown-tables	        \
      	imagecodecs		        \
		albumentations

# Removing unneeded vulnerable binaries
RUN dnf remove -y    \
    binutils         \
    glibc-devel      \
    glibc-headers    \
    kernel-headers

# Removing identified secret and SUID files
RUN rm -rf /usr/share/doc/perl-IO-Socket-SSL/certs/                             && \
    rm -rf /usr/share/doc/perl-IO-Socket-SSL/example/                           && \
    rm -rf /usr/share/doc/perl-IO-Socket-SSL/example/                           && \
    rm -rf /usr/share/doc/perl-Net-SSLeay/examples/server_key.pem               && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/tornado/test/test.key   && \
    chmod g-s /usr/libexec/openssh/ssh-keysign

RUN usermod -u 1002 python  && \
    usermod -u 1001 jovyan

USER root

# The following does not produce the desired results
  # jupyter kernelspec uninstall python3 -y
  # jupyter kernelspec list
# No longer needed, modified kernel.json file instead
  # python3.8 -m ipykernel install --name='AI_Packages' --display-name 'Python3.8 (AI_Packages)' --user

RUN rm -f /opt/jupyter/venv/share/jupyter/kernels/python3/kernel.json   && \
    rmdir $HOME/work
#COPY kernel.json /opt/jupyter/venv/share/jupyter/kernels/python3/kernel.json

USER 1001

WORKDIR /home/jovyan

ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

EXPOSE 8888

HEALTHCHECK CMD pgrep "jupyter" > /dev/null || exit 1
