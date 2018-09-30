#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

DEFTCHAIND=${DEFTCHAIND:-$BINDIR/deftchaind}
DEFTCHAINCLI=${DEFTCHAINCLI:-$BINDIR/deftchain-cli}
DEFTCHAINTX=${DEFTCHAINTX:-$BINDIR/deftchain-tx}
DEFTCHAINQT=${DEFTCHAINQT:-$BINDIR/qt/deftchain-qt}

[ ! -x $DEFTCHAIND ] && echo "$DEFTCHAIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BTCVER=($($DEFTCHAINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for deftchaind if --version-string is not set,
# but has different outcomes for deftchain-qt and deftchain-cli.
echo "[COPYRIGHT]" > footer.h2m
$DEFTCHAIND --version | sed -n '1!p' >> footer.h2m

for cmd in $DEFTCHAIND $DEFTCHAINCLI $DEFTCHAINTX $DEFTCHAINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
