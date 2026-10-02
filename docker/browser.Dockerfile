FROM selenium/standalone-chrome:latest

# Pre-create the profile dir so the named volume mounted here is owned by seluser.
RUN mkdir -p /home/seluser/chrome-profile
