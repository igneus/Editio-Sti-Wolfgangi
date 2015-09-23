RUBY_COMMAND = ruby
GREGORIO = gregorio
LUALATEX = lualatex
SED = sed
AWK = awk
GREP = grep
CAT = cat
CP = cp
MV = mv
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
PSALMS = 4 62 90 92 99 109 110 111 112 113 118v_x 118xi_xvi 118xvii_xxii 133 143i 143ii 144i_vii 144viii_xiii 144xiv_xxi 148 149 150
include tonus.mk
MODUS-4 = viii-G
MODUS-62 = vii-a
MODUS-90 = viii-G
MODUS-92 = i-g
MODUS-99 = vii-d
MODUS-109 = i-g
MODUS-110 = vii-d
MODUS-111 = vii-a
MODUS-112 = i-f
MODUS-113 = iii-a
MODUS-118v_x = vii-d
MODUS-118xi_xvi = vii-a
MODUS-118xvii_xxii = iii-a
MODUS-133 = viii-G
MODUS-143i = i-g
MODUS-143ii = vii-d
MODUS-144i_vii = vii-a
MODUS-144viii_xiii = i-f
MODUS-144xiv_xxi = iii-a
MODUS-148 = iii-a
MODUS-149 = iii-a
MODUS-150 = iii-a
MODUS-benedictus = isoll-f
MODUS-magnificat = viisoll-a
MODUS-magnificat2 = viiisoll-G2
MODUS-nuncdimittis = iii-a
MODUS-dan3 = i-f
MODUSLIST = $(sort $(foreach P,$(PSALMS) benedictus magnificat magnificat2 nuncdimittis dan3,$(MODUS-$(P))))
CZPSALMOPTS = --accents 0:0 --title-pattern " " --no-paragraph
CZPSALMS = $(patsubst %,$(TMP_DIR)/ps%-boh.tex,$(PSALMS))
ALLCZPSALMS = $(CZPSALMS) $(patsubst %,$(TMP_DIR)/%-boh.tex,benedictus magnificat nuncdimittis dan3)
ALLCOMBPSALMS = $(patsubst $(TMP_DIR)/%-boh.tex,$(TMP_DIR)/%-comb.tex,$(ALLCZPSALMS))
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
SCORES = $(addprefix ant,1 2 3 4 5) ant-magn-vesp1 ant-magn-vesp2 ant-ben-laud \
	 $(addprefix versus-,rorate voxclamantis custodi angelus veni ostende super) \
	 $(addprefix hym-,ConditorAlme VoxClara TeLucis NuncSancte RectorPotens RerumDeus) \
	 benedicamus-dominica-advequad \
	 deusinadiutorium-alter supplicatiolitaniae oratiodominica resp-vesp resp-laud \
	 dominusvobiscum-solemnis domineexaudi magnificat-initium-vii-a \
	 magnificat-initium-viii-G2 oratio \
	 $(addprefix capitulum-,FratresQuaecumque tuautem DeusAutemPatientiae DeusAutemSpei) \
	 benedictio-noctemquietam jubedomnebenedicere lectiobrevis-fratressobrii \
	 convertenosdeus ant-miserere deusinadiutorium-communis \
	 resp-inmanus ant-salvanos-antiquo \
	 oratio-visita benedicamus-minor an_alma_redemptoris_mater \
	 oratio-AlmaRedemptorisAdvent divinumauxilium oratiodominica-mat
#	 introitus-GaudeamusOmnes graduale-BenedictaEtVenerabilis \
#	 alleluia-SolemnitasGloriosae offertorium-BeataEs \
#	 communio-BeatamMeDicent communio-versus-Magnificat \
#	 ix-agnusdei ix-gloria ix-kyrie ix-sanctus credo-iii
OTHERSCORES = $(patsubst %,$(TMP_DIR)/%.gtex,$(SCORES))
OTHERDEPS = $(patsubst %,cantus/amon33/hym-%-bohtext.tex,ConditorAlme VoxClara TeLucis NuncSancte RectorPotens RerumDeus) \
	    $(TMP_DIR)/magnificat2-comb.tex
LAPSALMSINITGABC = $(foreach P,$(PSALMS),$(TMP_DIR)/ps$(P)-initium-$(MODUS-$(P))-auto.gabc) \
		   $(foreach P,dan3 benedictus nuncdimittis,$(TMP_DIR)/$(P)-initium-$(MODUS-$(P))-auto.gabc)
LAPSALMSINITTEX = $(patsubst %.gabc,%.gtex,$(LAPSALMSINITGABC))
GENINITIUM = cd $(TMP_DIR) && $(RUBY_COMMAND) ../$(INITIUM_TOOL) ../$(1) ../$(PSALMTONES_DIR)/$(2)-auto.gabc; \
	     [ $(2) = "dir" ] && cd .. && $(SED) -i -e '/(::)$$$$/{/(,) (::)$$$$/!{s/<b>//g;s/<\/b>//g}}' $(3) && cd $(TMP_DIR) || :; \
	     case "$(1)" in */ps118[ivx]*) cd .. && $(SED) -i -e 's/^( )/( )<v>\\hebinitial{'`$(AWK) -f hebletter.awk -v PSLM="$(1)"`'}<\/v>/' $(3);; esac || :
iter = $(patsubst %,iterator.mk,$(iter-left))
define iter-doit
$(TMP_DIR)/%-initium-$(i)-auto.gabc: $(PSALMS_DIR)/%.pslm $(PSALMTONES_DIR)/$(i)-auto.gabc; $(call GENINITIUM,$$<,$(i),$$@)
endef
iter-left := $(MODUSLIST)
include $(iter)
define iter-doit
$(TMP_DIR)/%.gtex: $(i)/%.gabc ; if $(GREP) -q ^nabc-lines: $$<; then $(SED) -e ':d;s/\(([^).]*\)\./\1/g;/([^)]*\./bd' $$<; else $(CAT) $$<; fi | $(SED) -e 's/<sp>\([AVR]\)\/<\/sp>\./<v>\\\1bardot{}<\/v>/g;s/†/ +/g;:d;s/\(([^)'\'']*\)'\''/\1/g;/([^)]*'\''/bd' | $(SED) -e ':d;s/\(\(^\|)\)[^(j]*\)j/\1i/g;s/\(\(^\|)\)[^(J]*\)J/\1I/g;td' | $(GREGORIO) -s -o $$@
endef
iter-left := . $(TMP_DIR) $(addprefix cantus/,amon33 arom12 triplex76) \
	     $(addprefix $(COMMON_CHANTS_DIR)/,kyriale76 amon33 arom12 lcantualis78) $(PSALMTONES_DIR) \
	     $(addprefix ../Epiphania/cantus/,arom12 grom61 cselecti57 triplex76)
include $(iter)

all: adventusdominicaii.pdf
$(TMP_DIR)/%.tex: PSALMOPTS = $(APPENDGLORIAPATRI) $(LAPSALMOPTS)
$(patsubst %,$(TMP_DIR)/%.tex,ps4 ps148 ps149 dan3): PSALMOPTS = $(LAPSALMOPTS)
$(TMP_DIR)/magnificat.tex: PSALMOPTS = $(APPENDGLORIAPATRI) --accents-style bold --skip-verses 2 $(LAPSALMOPTSACC)
$(TMP_DIR)/magnificat2.tex: PSALMOPTS = $(APPENDGLORIAPATRI) --accents-style bold --skip-verses 2 $(LAPSALMOPTSACC)
$(TMP_DIR)/ps90.tex: PSALMOPTS = --accents-style bold $(LAPSALMOPTSACC)
$(TMP_DIR)/ps133.tex: PSALMOPTS = $(APPENDGLORIAPATRI) --accents-style bold $(LAPSALMOPTSACC)
$(TMP_DIR)/%-boh.tex: PSALMOPTS = $(CZPSALMOPTS)
$(CZPSALMS) $(TMP_DIR)/benedictus-boh.tex: $(TMP_DIR)/%-boh.tex: $(CZECH_PSALMS_DIR)/Hejcl1922/%.pslm
	$(GENPSALM)
$(TMP_DIR)/dan3-boh.tex: $(CZECH_PSALMS_DIR)/Pavlik/dan3.pslm
	$(GENPSALM)
$(patsubst %,$(TMP_DIR)/%-boh.tex, magnificat nuncdimittis): $(TMP_DIR)/%-boh.tex: $(CZECH_PSALMS_DIR)/DMC199x/%.pslm
	$(GENPSALM)
$(LAPSALMS): $(TMP_DIR)/ps%.tex: $(PSALMS_DIR)/ps%.pslm
	$(GENPSALM)
	case "$<" in */ps118[ivx]*) $(AWK) -f hebletter.awk -v PSLM="$<" -v TEX=1 $@ > $@.tmp; $(MV) -f $@.tmp $@;; esac || :
	$(SED) -i -e 'y/Jj/Ii/' $@
$(LAPSALMSEXTRA): $(TMP_DIR)/%.tex: $(PSALMS_DIR)/%.pslm
	$(GENPSALM)
	$(SED) -i -e 'y/Jj/Ii/' $@
$(TMP_DIR)/magnificat2.tex: $(PSALMS_DIR)/magnificat.pslm
	$(GENPSALM)
	$(SED) -i -e 'y/Jj/Ii/' $@
$(ALLCOMBPSALMS): $(TMP_DIR)/%-comb.tex: $(TMP_DIR)/%.tex $(TMP_DIR)/%-boh.tex
	$(GENPSCOMB)
$(TMP_DIR)/magnificat2-comb.tex: $(TMP_DIR)/magnificat2.tex $(TMP_DIR)/magnificat-boh.tex
	$(GENPSCOMB)
$(TMP_DIR)/magnificat-comb.tex: PSSKIP = 2
$(TMP_DIR)/magnificat2-comb.tex: PSSKIP = 2
adventusdominicaii.pdf: adventusdominicaii.tex conventuscommune.tex translationes_cs.tex \
	       $(ALLCZPSALMS) $(ALLLAPSALMS) $(ALLCOMBPSALMS) $(LAPSALMSINITTEX) $(OTHERSCORES) $(OTHERDEPS) \
	       imagines/imago_Sion.jpg
	$(LUALATEX) -interaction=nonstopmode $<
	$(LUALATEX) -interaction=nonstopmode $<
clean:
	-rm -rf $(TMP_DIR) *~ *.aux *.gaux *.greaux *.log
.PHONY: clean
