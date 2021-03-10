FROM ubuntu:18.04 

RUN apt-get update
RUN apt-get upgrade -y
# Avoid problem with tzdata install...
# Sets timezone to UTC though
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Install dependencies
RUN apt-get install -y locales locales-all python3 python3-pip wget pkg-config curl git mc net-tools make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl gcc-avr avr-libc gcc-arm-none-eabi make dos2unix jq pandoc libmpfr-dev libmpc-dev vim usbutils libusb-1.0.0-dev  

RUN apt-get install -y libfreetype6-dev libpng-dev libopenblas-base libopenblas-dev gfortran libxml2-dev libxslt-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev llvm-9 llvm-9-tools llvm-9-dev

# add llvm-config to path
ENV PATH="${PATH}:/usr/lib/llvm-9/bin"

# Copy udev rules
COPY 99-newae.rules /etc/udev/rules.d/99-newae.rules

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Python Packages
# needed first for other libraries, numpy pinned to version for pandas pinned version
RUN pip3 install --no-cache-dir wheel pip cython numpy==1.16.6
RUN pip3 install cufflinks; \
    pip3 install plotly; \
    pip3 install phoenixAES; \
    pip3 install terminaltables; \
    pip3 install nbparameterise; \
    pip3 install gmpy2
RUN pip3 install fastdtw; \
    pip3 install tqdm; \
    pip3 install colorama
#RUN pip3 install scared; \ # fails due to newer GCC version and removed glibc 2.26
#RUN pip3 install --no-cache-dir scipy==1.1.0 

# Download chipwhisperer
#RUN mkdir -p /opt
WORKDIR /opt
RUN git clone --recursive --depth=1 https://github.com/newaetech/chipwhisperer.git

# Install chipwhisperer
WORKDIR /opt/chipwhisperer/
RUN pip3 install -r software/requirements.txt 
RUN python3 setup.py develop

# Install jupyter and the jupyter dependencies
WORKDIR /opt/chipwhisperer/jupyter
RUN pip3 install -r requirements.txt

RUN jupyter contrib nbextension install --system
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable collapsible_headings/main
RUN jupyter nbextensions_configurator enable

#https://github.com/newaetech/phywhispererusb.git
# Download chipwhisperer
#RUN mkdir -p /opt/phywhispererusb
WORKDIR /opt
RUN git clone --recursive --depth=1 https://github.com/newaetech/phywhispererusb.git

## Install phywhispererusb
WORKDIR /opt/phywhispererusb
RUN pip3 install -r software/requirements.txt 
RUN python3 setup.py develop

# Create workspace directory (This is where we mount user data)
RUN mkdir -p /cw_workspace
WORKDIR /cw_workspace

# Create home directory
RUN mkdir -p /home
RUN chmod 777 /home

# Entrypoint is directly the jupyter notebook
CMD jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --no-browser --NotebookApp.token=${TOKEN}
