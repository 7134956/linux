#
# Makefile for the VFD drivers.
#

obj-$(CONFIG_VFD_SUPPORT)	+= vfd.o

vfd-y				+= vfd-core.o vfd-glyphs.o
vfd-$(CONFIG_VFD_PT6964)	+= pt6964.o
vfd-$(CONFIG_VFD_PT6964_X92)	+= vfd-ca.o
vfd-$(CONFIG_VFD_PT6964_T95U)	+= vfd-cc.o
