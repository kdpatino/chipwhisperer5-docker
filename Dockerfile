FROM ubuntu:20.04

RUN apt update
# Avoid problem with tzdata install...
# Sets timezone to UTC though
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Install dependencies
RUN apt install -y libusb-dev make git python3 python3-pip python3-tk wget pkg-config
RUN apt install -y libusb-1.0-0 libusb-1.0-0-dev
RUN apt install -y libpng-dev libfreetype6-dev python3-pandas
RUN apt install -y avr-libc gcc-avr gcc-arm-none-eabi

# Copy udev rules
COPY 99-newae.rules /etc/udev/rules.d/99-newae.rules

# Download chipwhisperer
RUN mkdir -p /opt/chipwhisperer
WORKDIR /opt/Chipwhisperer5
RUN git clone https://github.com/newaetech/chipwhisperer.git

WORKDIR /opt/Chipwhisperer5/chipwhisperer
RUN git submodule update --init jupyter
RUN python3 -m pip install -r jupyter/requirements.txt 
RUN python3 -m pip install -e .
RUN python3 setup.py develop

RUN git submodule update --init openadc
WORKDIR /opt/Chipwhisperer5/chipwhisperer/openadc/controlsw/python
RUN python3 -m pip install -e .

# Create workspace directory (This is where we mount user data)
RUN mkdir -p /cw_workspace
WORKDIR /cw_workspace

# Create home directory
RUN mkdir -p /home
RUN chmod 777 /home

# Entrypoint is directly the jupyter notebook
CMD jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --no-browser --NotebookApp.token=${TOKEN}  