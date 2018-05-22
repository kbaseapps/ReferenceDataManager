FROM kbase/kbase:sdkbase2.latest
MAINTAINER KBase Developer
# -----------------------------------------

# Insert apt-get instructions here to install
# any required dependencies for your module.

RUN apt-get update && apt-get install -y emacs
RUN apt-get install libdatetime-format-strptime-perl
RUN cpanm -i Config::IniFiles

# -----------------------------------------

COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod -R 777 /kb/module

WORKDIR /kb/module

RUN make

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
