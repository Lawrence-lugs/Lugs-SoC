# Use the locally-cached tag; pin to a dated tag (e.g. 2024.12) for reproducibility.
FROM hpretl/iic-osic-tools:latest

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

USER root

# ==============================================================================
# [vim_deploy] INJECTION START
# ==============================================================================
# 1. Install prerequisites
RUN apt-get update && apt-get install -y git curl wget 

# 2. Clone and Run the Installer
# NOTE: We clone to a permanent path (/root/.vim_deploy) and DO NOT delete it.
# The install.sh creates symlinks to this folder. If we deleted it, the config would break.
RUN git clone https://github.com/Lawrence-lugs/vim_deploy /root/.vim_deploy && \
    cd /root/.vim_deploy && \
    bash install.sh

# 3. Update PATH and ALIASES for the image
# NOTE: iic_osic_tools sets HOME=/headless for ALL users (including root),
#       so miniforge lands in /headless/miniforge3, not /root/miniforge3.
#       /foss/tools/bin is normally added by the entrypoint at runtime; we
#       bake it into ENV so it is available unconditionally (e.g. docker exec).
ENV PATH="/headless/miniforge3/bin:/foss/tools/bin:/foss/tools/sak:$PATH"

RUN echo "alias vim=nvim" >> /headless/.bash_aliases
# ==============================================================================
# [vim_deploy] INJECTION END
# ==============================================================================

# Install project-level Python analysis packages into the base conda env.
# The vim_deploy install.sh already set up nvim + verible + LSPs in base.
COPY .devcontainer/environment.yml /tmp/project_environment.yml
RUN mamba env update -n base -f /tmp/project_environment.yml && \
    conda clean -afy


WORKDIR /workspace
