.PRECIOUS: %.blif  # ADD THIS LINE
PROJ = doppler_custom
PIN_DEF = doppler.pcf
DEVICE = up5k

all: $(PROJ).rpt $(PROJ).bin header

%.blif: %.v

	yosys -v 3 -p 'synth_ice40  -top $(PROJ) -blif $@' $< util.v synthlib.v synth.v led16.v

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d 5k  -o $@ -p $^ -P sg48

header: $(PROJ).bin
	xxd -i $(PROJ).bin  > $(PROJ)_arduino/$(PROJ).h
	sed -i -r 's/unsigned/const unsigned/g' $(PROJ)_arduino/$(PROJ).h
	#cp $(PROJ).blif $(PROJ)_.blif

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	#iCEburn.py  -e -v -w  $<
	curl -F file=@doppler_simple_io.bin http://10.0.1.40/fupload 

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	iCEburn.py  -e -v -w  $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ)_arduino/$(PROJ).h

.PHONY: all prog clean
