RUBY_COMMAND = ruby
GREGORIO = gregorio
LUALATEX = lualatex
SED = sed
TMP_DIR = temporalia
ifneq ($(wildcard $(TMP_DIR)),$(TMP_DIR))
TD := $(shell mkdir $(TMP_DIR))
endif
EDITIO_ROOTDIR = ../..
TOOLS_DIR = $(EDITIO_ROOTDIR)/instrumenta
PSALMS_DIR = $(EDITIO_ROOTDIR)/psalmi/amon33
PSALMTONES_DIR = $(EDITIO_ROOTDIR)/tonipsalmorum/arom12
CZECH_PSALMS_DIR = $(EDITIO_ROOTDIR)/bohemice_psalmi
COMMON_CHANTS_DIR = $(EDITIO_ROOTDIR)/cantuscommunes
PSALM_PREPROCESSOR = $(TOOLS_DIR)/psalmpreprocessor.rb
INITIUM_TOOL = $(TOOLS_DIR)/initiumpsalmi.rb
PSALMS = 4 28 45 46 62 65 66 71 85 90 92 95 96 99 109 110 111 112 118v_vii 118viii_x 118xi_xiii 133 148 149 150
include tonus.mk
MODUS-4 = dir
MODUS-28 = vii-a
MODUS-45 = vi-F
MODUS-46 = i-f
MODUS-62 = i-g3
MODUS-65 = iv-E
MODUS-66 = dir
MODUS-71 = i-a2
MODUS-85 = iv-E
MODUS-90 = dir
MODUS-92 = ii-D
MODUS-95 = vi-F
MODUS-96 = vi-F
MODUS-99 = i-g2
MODUS-109 = ii-D
MODUS-110 = i-g2
MODUS-111 = i-g3
MODUS-112 = iv-E
MODUS-118v_vii = i-g2
MODUS-118viii_x = i-g3
MODUS-118xi_xiii = vii-c2
MODUS-133 = dir
MODUS-148 = vii-c2
MODUS-149 = vii-c2
MODUS-150 = vii-c2
MODUS-benedictus = viiisoll-G2
MODUS-magnificat = viiisoll-G2
MODUS-dan3 = iv-E
MODUSLIST = $(sort $(foreach P,$(PSALMS) benedictus magnificat dan3,$(MODUS-$(P))))
CZPSALMOPTS = --accents 0:0 --title-pattern " " --no-paragraph
CZPSALMS = $(patsubst %,$(TMP_DIR)/ps%-boh.tex,$(PSALMS))
ALLCZPSALMS = $(CZPSALMS) $(patsubst %,$(TMP_DIR)/%-boh.tex,dan3 benedictus magnificat)
GENPSALM = $(RUBY_COMMAND) $(PSALM_PREPROCESSOR) --output $@ $(PSALMOPTS) $< \
	   && $(SED) -i -e 's/\*/\\grestar{}/g' $@
TONUS = $(TONUS-$(MODUS-$*))
GLORIAPATRI = $(PSALMS_DIR)/gloriapatri.pslm
APPENDGLORIAPATRI = --append "`cat $(GLORIAPATRI)`"
LAPSALMOPTS_COMMON = --accents-style bold --skip-verses 1
LAPSALMOPTSACC = --accents $(word 1,$(TONUS)):$(word 3,$(TONUS)) \
		 --preparatory-syllables $(word 2,$(TONUS)):$(word 4,$(TONUS))
LAPSALMOPTS = $(LAPSALMOPTS_COMMON) $(LAPSALMOPTSACC)
LAPSALMS = $(patsubst %,$(TMP_DIR)/ps%.tex,$(PSALMS))
LAPSALMSEXTRA = $(patsubst %,$(TMP_DIR)/%.tex,benedictus magnificat dan3)
ALLLAPSALMS = $(LAPSALMS) $(LAPSALMSEXTRA)
SCORES = alleluia-VidimusStellam ant1 ant2 ant3 ant4 ant5 ant-ben-laud ant-magn-vesp1 \
	 ant-magn-vesp2 benedicamus-duplex-laudes benedicamus-duplex-vesperae \
	 capitulum-Surge communio-VidimusStellam communio-versus-DeusJudicium \
	 deusinadiutorium-communis domineexaudi dominusvobiscum-solemnis \
	 graduale-OmnesDeSaba hym-HostisHerodes hym-OSolaMagnarum \
	 introitus-EcceAdvenit ix-agnusdei ix-gloria ix-kyrie ix-sanctus \
	 magnificat-initium-i-D_ magnificat-initium-viii-G2 offertorium-RegesTharsis \
	 oratiodominica oratio resp1v respl supplicatiolitaniae versus-adorate \
	 versus-reges $(addprefix matant,1 2 3 4 5 6 7 8 9) $(addprefix matresp,1 2 3 4 5 6 7 8) \
	 ps94-initium-viii-G tedeum-solemnis annuntiatio \
	 hym-RerumDeus hym-RectorPotens hym-NuncSancte hym-TeLucis
OTHERSCORES = $(patsubst %,$(TMP_DIR)/%.tex,$(SCORES))
OTHERDEPS = cantus/amon33/hym-HostisHerodes-bohtext.tex cantus/amon33/hym-OSolaMagnarum-bohtext.tex \
	    cantus/nrom02/ps94.tex
LAPSALMSINITGABC = $(foreach P,$(PSALMS),$(TMP_DIR)/ps$(P)-initium-$(MODUS-$(P))-auto.gabc) \
		   $(foreach P,dan3 benedictus,$(TMP_DIR)/$(P)-initium-$(MODUS-$(P))-auto.gabc)
LAPSALMSINITTEX = $(patsubst %.gabc,%.tex,$(LAPSALMSINITGABC))
GENINITIUM = cd $(TMP_DIR) && $(RUBY_COMMAND) ../$(INITIUM_TOOL) ../$(1) ../$(PSALMTONES_DIR)/$(2)-auto.gabc
iter = $(patsubst %,iterator.mk,$(iter-left))
define iter-doit
$(TMP_DIR)/%-initium-$(i)-auto.gabc: $(PSALMS_DIR)/%.pslm $(PSALMTONES_DIR)/$(i)-auto.gabc; $(call GENINITIUM,$$<,$(i))
endef
iter-left := $(MODUSLIST)
include $(iter)
define iter-doit
$(TMP_DIR)/%.tex: $(i)/%.gabc ; $(GREGORIO) -o $$@ $$<
endef
iter-left := . $(TMP_DIR) cantus/amon33 cantus/nrom02 cantus/grom61 cantus/triplex76 \
	     cantus/otriplex85 $(addprefix $(COMMON_CHANTS_DIR)/,kyriale76 amon33) $(PSALMTONES_DIR)
include $(iter)

all: epiphania.pdf
$(TMP_DIR)/%.tex: PSALMOPTS = $(APPENDGLORIAPATRI) $(LAPSALMOPTS)
$(patsubst %,$(TMP_DIR)/%.tex,ps4 ps90 ps148 ps149 dan3): PSALMOPTS = $(LAPSALMOPTS)
$(TMP_DIR)/magnificat.tex: PSALMOPTS = $(APPENDGLORIAPATRI) --accents-style bold --skip-verses 2 $(LAPSALMOPTSACC)
$(TMP_DIR)/%-boh.tex: PSALMOPTS = $(CZPSALMOPTS)
$(CZPSALMS): $(TMP_DIR)/%-boh.tex: $(CZECH_PSALMS_DIR)/Hejcl1922/%.pslm
	$(GENPSALM)
$(TMP_DIR)/dan3-boh.tex: $(CZECH_PSALMS_DIR)/Pavlik/dan3.pslm
	$(GENPSALM)
$(TMP_DIR)/benedictus-boh.tex $(TMP_DIR)/magnificat-boh.tex: $(TMP_DIR)/%-boh.tex: $(CZECH_PSALMS_DIR)/DMC199x/%.pslm
	$(GENPSALM)
$(LAPSALMS): $(TMP_DIR)/ps%.tex: $(PSALMS_DIR)/ps%.pslm
	$(GENPSALM)
$(LAPSALMSEXTRA): $(TMP_DIR)/%.tex: $(PSALMS_DIR)/%.pslm
	$(GENPSALM)
epiphania.pdf: epiphania.tex conventuscommune.tex translationes_cs.tex \
	       $(ALLCZPSALMS) $(ALLLAPSALMS) $(LAPSALMSINITTEX) $(OTHERSCORES) $(OTHERDEPS)
	$(LUALATEX) -interaction=nonstopmode $<
	$(LUALATEX) -interaction=nonstopmode $<
clean:
	-rm -rf $(TMP_DIR) *~ *.aux *.gaux *.log
.PHONY: clean
