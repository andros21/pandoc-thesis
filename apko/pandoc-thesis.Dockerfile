# pandoc-thesis.Dockerfile
# ========================
# setup from pandoc-thesis apko base image
# ----------------------------------------

FROM ghcr.io/andros21/pandoc-thesis:master-apko
RUN curl -sSf ${TEXLIVE_TRIGGER_URL} | sh
RUN curl -sSf ${JAVA_TRIGGER_URL} | sh
RUN dot -c
RUN python3 -m venv --system-site-packages /opt/imagine
RUN /opt/imagine/bin/pip install git+${PANDOC_FILTERS_REPO}@${PANDOC_FILTERS_VERSION}
RUN /opt/imagine/bin/pip install git+${PANDOC_IMAGINE_REPO}@${PANDOC_IMAGINE_VERSION}
ENV PATH="/opt/imagine/bin/:${PATH}"
USER nonroot
ENTRYPOINT ["pandoc"]
