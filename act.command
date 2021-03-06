#!/bin/sh -

# This script will start ACT on a UNIX system.  This script should
# be left in the same directory as the rest of the ACT
# distribution, so that the java class files can be found.  If
# necessary a symbolic link can be made to this script from
# /usr/local/bin/ or elsewhere.


# $Header: //tmp/pathsoft/artemis/act.command,v 1.1 2005-06-20 09:56:09 tjc Exp $

# resolve links - $0 may be a link
PRG=$0
progname=`basename $0`

#PSU_PROD_JAVA_VERSION=1.4.2
#. $PSU_CONFIG_DIR/shell/java_environment.sh

while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '.*/.*' > /dev/null; then
    PRG="$link"
  else
    PRG="`dirname $PRG`/$link"
  fi
done

ACT_HOME=`dirname "$PRG"`/.


CLASSPATH=$ACT_HOME:$ACT_HOME/lib/JacORB.jar:$ACT_HOME/lib/jemAlign.jar:$ACT_HOME/lib/jakarta-regexp-1.2.jar:$ACT_HOME/lib/macos.jar:$CLASSPATH

export CLASSPATH

ACT_PROPERTIES="-Dartemis.environment=UNIX"

MEM="-mx150m -ms20m"

if [ "$JVM_FLAGS" = "" ]
then
    FLAGS="$MEM -noverify"
else
    FLAGS="$MEM -noverify $JVM_FLAGS"
fi


# work-around for OSF JVM core dump problem
if [ `uname` = OSF1 ]
then
    FLAGS="$FLAGS -Dsimple_splash_screen=true"
fi


QUIET=no

if [ $# = 0 ]
then
    :
else
    if [ x$1 = x-h -o x$1 = x--help ]
    then
        cat <<EOF
usage: $0 [EMBL/GENBANK/SEQUENCE file] [EMBL/GENBANK/SEQUENCE file] [crunch file]
EOF
        exit 0
    fi


    while test $# != 0
    do
        case $1 in
        -options) FLAGS="$FLAGS -Dextra_options=$2"; shift ;;
        -D*) FLAGS="$FLAGS $1" ;;
        -fast) FLAGS="$FLAGS -fast" ;;
        -quiet) QUIET=yes ; FLAGS="$FLAGS -Drun_quietly=true" ;;
        -debug) DEBUG=yes ;;
        *) break ;;
        esac
        shift
    done
fi

if [ "$JAVA_VM" = "" ]
then
    if [ "$DEBUG" = yes ]
    then
        JAVA=java_g
    else
        JAVA=java
    fi
else
    JAVA=$JAVA_VM
fi


if [ $QUIET = no ]
then
    echo starting ACT with flags: $FLAGS 1>&2
fi

$JAVA -Dcom.apple.mrj.application.apple.menu.about.name="ACT" $FLAGS $ACT_PROPERTIES uk.ac.sanger.artemis.components.ActMain $*

