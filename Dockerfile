FROM ubuntu:19.10

RUN apt-get update
# Avoid problem with tzdata install...
# Sets timezone to UTC though
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Install dependencies
RUN apt-get install -y python3 python3-pip python3-tk wget git pkg-config libfreetype6-dev libpng-dev libusb-1.0.0 libusb-1.0.0-dev libopenblas-base libopenblas-dev gfortran libxml2-dev libxslt-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python3-tk libharfbuzz-dev libfribidi-dev libxcb1-dev python3-llvmlite llvm llvm-9-tools
RUN apt-get install -y avr-libc gcc-avr gcc-arm-none-eabi

# Copy udev rules
COPY 99-newae.rules /etc/udev/rules.d/99-newae.rules

# Python Packages
RUN pip3 install --no-cache-dir cython numpy
RUN pip3 install --no-cache-dir scipy==1.1.0 

# Download chipwhisperer
RUN mkdir -p /opt/chipwhisperer
WORKDIR /opt/chipwhisperer
RUN git clone --recursive --depth=1 https://github.com/newaetech/chipwhisperer.git

# Install chipwhisperer
WORKDIR /opt/chipwhisperer/chipwhisperer/
RUN pip3 install -r software/requirements.txt 
RUN python3 setup.py develop

# Install jupyter and the jupyter dependencies
WORKDIR /opt/chipwhisperer/chipwhisperer/jupyter
RUN pip3 install -r requirements.txt


#https://github.com/newaetech/phywhispererusb.git
# Download chipwhisperer
#RUN mkdir -p /opt/pywhispererusb
#WORKDIR /opt/pywhispererusb
#RUN git clone --recursive --depth=1 https://github.com/newaetech/pywhispererusb.git

## Install pywhispererusb
#WORKDIR /opt/pywhispererusb/
#RUN pip3 install -r software/requirements.txt 
#RUN python3 setup.py develop

# Create workspace directory (This is where we mount user data)
RUN mkdir -p /cw_workspace
WORKDIR /cw_workspace

# Create home directory
RUN mkdir -p /home
RUN chmod 777 /home

# Entrypoint is directly the jupyter notebook
CMD jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --no-browser --NotebookApp.token=${TOKEN}
