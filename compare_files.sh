#!/usr/bin/env bash

A="${1}"
B="${2}"

T=$(mktemp)
MissingFromA=$(mktemp)
MissingFromB=$(mktemp)
PresentInBoth=$(mktemp)
trap 'rm -Rf "${T}"; rm -Rf "${MissingFromA}"; rm -Rf "${MissingFromB}"; rm -Rf "${PresentInBoth}"; exit' ERR EXIT HUP INT

cat "${A}" "${B}" | sort -u > "${T}"

A_title="$(echo ${A} | cut -c -7)..."
B_title="$(echo ${B} | cut -c -7)..."

FORMAT="%-15s | %-15s | %-15s\n"

printf "${FORMAT}" "Item" "${A_title}" "${B_title}"

cat "${T}" | while read x
do
 A_count=$(grep -i -c "${x}" "${A}")
 B_count=$(grep -i -c "${x}" "${B}")
 printf "${FORMAT}" "${x}" "${A_count}" "${B_count}"

 if [ "${A_count}" != "0" ] && [ "${B_count}" != "0" ]; then
  echo "${x}" >> "${PresentInBoth}"
 fi

 if [ "${A_count}" != "0" ] && [ "${B_count}" = "0" ]; then
  echo "${x}" >> "${MissingFromB}"
 fi

 if [ "${A_count}" = "0" ] && [ "${B_count}" != "0" ]; then
  echo "${x}" >> "${MissingFromA}"
 fi

done

echo; echo; echo "Present in both:"
echo "========================="
cat "${PresentInBoth}"


echo; echo; echo "Present in [${A}], Missing from [${B}]:"
echo "========================="
cat "${MissingFromB}"


echo; echo; echo "Missing from [${A}], Present in [${B}]:"
echo "========================="
cat "${MissingFromA}"

echo; echo
