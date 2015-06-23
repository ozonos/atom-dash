# Basic Makefile

UUID = atom-launcher@ozonos.org
BASE_MODULES = extension.js stylesheet.css metadata.json LICENSE.md README.md
EXTRA_MODULES = freqView.js convenience.js prefs.js
TOLOCALIZE = prefs.js
MSGSRC = $(wildcard po/*.po)
INSTALLBASE = /usr/share/gnome-shell/extensions

all: extension

clean:
	rm -f ./schemas/gschemas.compiled

extension: ./schemas/gschemas.compiled $(MSGSRC:.po=.mo)

./schemas/gschemas.compiled: ./schemas/org.gnome.shell.extensions.atom-launcher.gschema.xml
	glib-compile-schemas ./schemas/

potfile: ./po/atomlauncher.pot

mergepo: potfile
	for l in $(MSGSRC); do \
		msgmerge -U $$1 ./po/atomlauncher.pot; \
	done;

./po/atomlauncher.pot: $(TOLOCALIZE)
	mkdir -p po
	xgettext -k_ -kN_ -o po/atomlauncher.pot --package-name "Atom Launcher" $(TOLOCALIZE)

./po/%.mo: ./po/%.po
	msgfmt -c $< -o $@

install: install-local

install-local: _build
	rm -rf $(INSTALLBASE)/$(UUID)
	mkdir -p $(INSTALLBASE)/$(UUID)
	cp -r ./_build/* $(INSTALLBASE)/$(UUID)/
	-rm -fR _build
	echo done

zip-file: _build
	cd _build ; \
	zip -qr "$(UUID).zip" .
	mv _build/$(UUID).zip ./
	-rm -fR _build

_build: all
	-rm -fR ./_build 
	mkdir -p _build 
	cp $(BASE_MODULES) $(EXTRA_MODULES) _build
	mkdir -p _build/schemas
	cp schemas/*.xml _build/schemas/
	cp schemas/gschemas.compiled _build/schemas/
	mkdir -p _build/locale
	for l in $(MSGSRC:.po=.mo) ; do \
		lf=_build/locale/`basename $$l .mo`; \
		mkdir -p $$lf; \
		mkdir -p $$lf/LC_MESSAGES; \
		cp $$l $$lf/LC_MESSAGES/atom-dash.mo; \
	done;


#What does the first "-" mean at the beginning of the line in a Makefile ? 
#It means that make itself will ignore any error code from rm. 
#In a makefile, if any command fails then the make process itself discontinues 
#processing. By prefixing your commands with -, you notify make that it should 
#continue processing rules no matter the outcome of the command.

#mkdir -p, --parents no error if existing, make parent directories as needed 



