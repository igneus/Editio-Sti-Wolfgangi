RUBY_COMMAND = ruby
GREGORIO = gregorio
LUALATEX = lualatex
SED = sed
AWK = awk
CP = cp
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
PSSKIP = 1
GENPSCOMB = $(AWK) -f pscomb.awk -v PSSKIP=$(PSSKIP) -v TRFILE=$(word 2,$^) $< > $@
PSALMS = 4 28 45 46 62 65 71 85 90 92 95 96 99 109 110 111 112 113 116 118v_x 118xi_xvi 118xvii_xxii 133 148 149 150
include tonus.mk
MODUS-4 = viii-G
MODUS-28 = vii-a
MODUS-45 = vi-F
MODUS-46 = i-f
MODUS-62 = i-g3
MODUS-65 = iv-E
MODUS-71 = i-a2
MODUS-85 = iv-E
MODUS-90 = viii-G
MODUS-92 = ii-D
MODUS-95 = vi-F
MODUS-96 = vi-F
MODUS-99 = i-g2
MODUS-109 = ii-D
MODUS-110 = i-g2
MODUS-111 = i-g3
MODUS-112 = iv-E
MODUS-113 = vii-c2
MODUS-116 = vii-c2
MODUS-118v_x = i-g2
MODUS-118xi_xvi = i-g3
MODUS-118xvii_xxii = vii-c2
MODUS-133 = viii-G
MODUS-148 = vii-c2
MODUS-149 = vii-c2
MODUS-150 = vii-c2
MODUS-benedictus = viiisoll-G2
MODUS-magnificat = viiisoll-G2
MODUS-nuncdimittis = iii-a
MODUS-dan3 = iv-E
MODUSLIST = $(sort $(foreach P,$(PSALMS) benedictus magnificat nuncdimittis dan3,$(MODUS-$(P))))
CZPSALMOPTS = --accents 0:0 --title-pattern " " --no-paragraph
CZPSALMS = $(patsubst %,$(TMP_DIR)/ps%-boh.tex,$(PSALMS))
ALLCZPSALMS = $(CZPSALMS) $(patsubst %,$(TMP_DIR)/%-boh.tex,dan3 benedictus magnificat nuncdimittis)
ALLCOMBPSALMS = $(patsubst $(TMP_DIR)/%-boh.tex,$(TMP_DIR)/%-comb.tex,$(ALLCZPSALMS)) $(TMP_DIR)/ps94-comb.tex
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
LAPSALMSEXTRA = $(patsubst %,$(TMP_DIR)/%.tex,benedictus magnificat nuncdimittis dan3)
ALLLAPSALMS = $(LAPSALMS) $(LAPSALMSEXTRA)
SCORES = alleluia-VidimusStellam ant1 ant2 ant3 ant4 ant5 ant-ben-laud ant-magn-vesp1 \
	 ant-magn-vesp2 communio-VidimusStellam communio-versus-DeusJudicium-initium \
	 deusinadiutorium-communis domineexaudi dominusvobiscum-solemnis \
	 graduale-OmnesDeSaba hym-HostisHerodes hym-OSolaMagnarum hym-CrudelisHerodes credo-i \
	 introitus-EcceAdvenit ii-agnusdei ii-gloria ii-kyrie ii-sanctus \
	 magnificat-initium-i-D_ magnificat-initium-viii-G2 offertorium-RegesTharsis \
	 oratiodominica oratio resp1v respl supplicatiolitaniae tuautem \
	 $(addprefix matant,1 2 3 4 5 6 7 8 9) $(addprefix matresp,1 2 3 4 5 6 7 8) \
	 ps94-initium-viii-G ps94-boh tedeum-solemnis annuntiatio \
	 hym-RerumDeus hym-RectorPotens hym-NuncSancte hym-TeLucis \
	 benedictio-noctemquietam jubedomnebenedicere lectiobrevis-fratressobrii \
	 convertenosdeus ant-miserere deusinadiutorium-solemnis \
	 capitulum-tuautem resp-inmanus ant-salvanos versus-custodi \
	 oratio-visita benedicamus-minor an_alma_redemptoris_mater \
	 versus-omnis versus-adorate-mat oratiodominica-mat \
	 absolutio-exaudi absolutio-ipsius absolutio-avinculis \
	 $(addprefix benedictio-solemn-,benedictione unigenitus spiritus deus christus ignem evangelica divinum perevangelica) \
	 $(addprefix benedicamus-solemnis-,laud 1vesp 2vesp) \
	 $(addprefix versus-,adorate adorate-simplex reges reges-simplex omnes) \
	 $(addprefix capitulum-,Surge Leva Omnes) tedecetlaus tonus-evangelii-b
OTHERSCORES = $(patsubst %,$(TMP_DIR)/%.tex,$(SCORES))
OTHERDEPS = cantus/amon33/hym-HostisHerodes-bohtext.tex cantus/amon33/hym-OSolaMagnarum-bohtext.tex \
	    cantus/nrom02/ps94.tex $(TMP_DIR)/communio-versus-DeusJudicium-comb.tex \
	    cantus/arom12/hym-CrudelisHerodes-bohtext.tex
LAPSALMSINITGABC = $(foreach P,$(PSALMS),$(TMP_DIR)/ps$(P)-initium-$(MODUS-$(P))-auto.gabc) \
		   $(foreach P,dan3 benedictus nuncdimittis,$(TMP_DIR)/$(P)-initium-$(MODUS-$(P))-auto.gabc)
LAPSALMSINITTEX = $(patsubst %.gabc,%.tex,$(LAPSALMSINITGABC))
GENINITIUM = cd $(TMP_DIR) && $(RUBY_COMMAND) ../$(INITIUM_TOOL) ../$(1) ../$(PSALMTONES_DIR)/$(2)-auto.gabc
iter = $(patsubst %,iterator.mk,$(iter-left))
define iter-doit
$(TMP_DIR)/%-initium-$(i)-auto.gabc: $(PSALMS_DIR)/%.pslm $(PSALMTONES_DIR)/$(i)-auto.gabc; $(call GENINITIUM,$$<,$(i))
endef
iter-left := $(MODUSLIST)
include $(iter)
define iter-doit
$(TMP_DIR)/%.tex: $(i)/%.gabc ; $(SED) -e 's/<sp>\([AVR]\)\/<\/sp>\./<v>\\\1bardot{}<\/v>/g' $$< | $(GREGORIO) -s -o $$@
endef
iter-left := . $(TMP_DIR) $(addprefix cantus/,amon33 nrom02 grom61 triplex76 otriplex85 arom12 cselecti57) \
	     $(addprefix $(COMMON_CHANTS_DIR)/,kyriale76 amon33 arom12) $(PSALMTONES_DIR)
include $(iter)

all: epiphania.pdf
$(TMP_DIR)/%.tex: PSALMOPTS = $(APPENDGLORIAPATRI) $(LAPSALMOPTS)
$(patsubst %,$(TMP_DIR)/%.tex,ps4 ps148 ps149 dan3): PSALMOPTS = $(LAPSALMOPTS)
$(TMP_DIR)/magnificat.tex: PSALMOPTS = $(APPENDGLORIAPATRI) --accents-style bold --skip-verses 2 $(LAPSALMOPTSACC)
$(TMP_DIR)/ps90.tex: PSALMOPTS = --accents-style bold $(LAPSALMOPTSACC)
$(TMP_DIR)/ps133.tex: PSALMOPTS = $(APPENDGLORIAPATRI) --accents-style bold $(LAPSALMOPTSACC)
$(TMP_DIR)/%-boh.tex: PSALMOPTS = $(CZPSALMOPTS)
$(CZPSALMS) $(TMP_DIR)/benedictus-boh.tex: $(TMP_DIR)/%-boh.tex: $(CZECH_PSALMS_DIR)/Hejcl1922/%.pslm
	$(GENPSALM)
$(TMP_DIR)/ps94-boh.tex: cantus/nrom02/ps94.pslm
	$(GENPSALM)
$(TMP_DIR)/dan3-boh.tex: $(CZECH_PSALMS_DIR)/Pavlik/dan3.pslm
	$(GENPSALM)
$(patsubst %,$(TMP_DIR)/%-boh.tex, magnificat nuncdimittis): $(TMP_DIR)/%-boh.tex: $(CZECH_PSALMS_DIR)/DMC199x/%.pslm
	$(GENPSALM)
$(TMP_DIR)/ps94.tex: cantus/nrom02/ps94.tex
	$(CP) $< $@
$(LAPSALMS): $(TMP_DIR)/ps%.tex: $(PSALMS_DIR)/ps%.pslm
	$(GENPSALM)
$(LAPSALMSEXTRA): $(TMP_DIR)/%.tex: $(PSALMS_DIR)/%.pslm
	$(GENPSALM)
$(TMP_DIR)/magnificat-comb.tex: PSSKIP = 2
$(TMP_DIR)/ps90-comb.tex $(TMP_DIR)/ps133-comb.tex: PSSKIP = 0
$(ALLCOMBPSALMS): $(TMP_DIR)/%-comb.tex: $(TMP_DIR)/%.tex $(TMP_DIR)/%-boh.tex
	$(GENPSCOMB)
$(TMP_DIR)/communio-versus-DeusJudicium-comb.tex: $(patsubst %,cantus/triplex76/communio-versus-DeusJudicium%tex,. -boh.)
	$(GENPSCOMB)
epiphania.pdf: epiphania.tex conventuscommune.tex translationes_cs.tex \
	       $(ALLCZPSALMS) $(ALLLAPSALMS) $(ALLCOMBPSALMS) $(LAPSALMSINITTEX) $(OTHERSCORES) $(OTHERDEPS)
	$(LUALATEX) -interaction=nonstopmode $<
	$(LUALATEX) -interaction=nonstopmode $<
clean:
	-rm -rf $(TMP_DIR) *~ *.aux *.gaux *.log
.PHONY: clean
