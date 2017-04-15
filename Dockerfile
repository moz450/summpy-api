FROM alpine:3.5
MAINTAINER moz450

ENV LANG C.UTF-8
ENV MECAB_VERSION 0.996
ENV IPADIC_VERSION 2.7.0-20070801
ENV mecab_url https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE
ENV ipadic_url https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM
ENV build_deps 'curl git bash file sudo openssh linux-headers build-base gcc make cmake g++ gfortran python-dev'
ENV dependencies 'openssl ca-certificates libstdc++ libgfortran python py-pip musl-dev lapack-dev'

RUN apk add --update --no-cache --virtual .build-deps ${build_deps} \
  # Install dependencies
  && apk add --update --no-cache ${dependencies} \
  && pip install --no-cache-dir --upgrade pip \
  # Fix numpy compilation
  && ln -s /usr/include/locale.h /usr/include/xlocale.h \
  # Install MeCab
  && curl -SL -o mecab-${MECAB_VERSION}.tar.gz ${mecab_url} \
  && tar zxf mecab-${MECAB_VERSION}.tar.gz \
  && cd mecab-${MECAB_VERSION} \
  && ./configure --enable-utf8-only --with-charset=utf8 \
  && make \
  && make install \
  && cd \
  # Install IPA dic
  && curl -SL -o mecab-ipadic-${IPADIC_VERSION}.tar.gz ${ipadic_url} \
  && tar zxf mecab-ipadic-${IPADIC_VERSION}.tar.gz \
  && cd mecab-ipadic-${IPADIC_VERSION} \
  && ./configure --with-charset=utf8 \
  && make \
  && make install \
  && cd \
  # Install Neologd
  && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
  && mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y \
  # Install summpy
  && pip install --no-cache-dir janome pulp summpy \
  # Clean up
  && apk del .build-deps \
  && rm -rf \
    mecab-${MECAB_VERSION}* \
    mecab-${IPADIC_VERSION}* \
    mecab-ipadic-neologd \
    ~/.cache

CMD ["python", "-m", "summpy.server", "-h", "0.0.0.0", "-p", "8080"]
