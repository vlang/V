module ftoa

const(
pow5_num_bits_32     = 61
pow5_inv_num_bits_32 = 59
pow5_num_bits_64     = 121
pow5_inv_num_bits_64 = 122

powers_of_10 = [
	u64(1e0),
	u64(1e1),
	u64(1e2),
	u64(1e3),
	u64(1e4),
	u64(1e5),
	u64(1e6),
	u64(1e7),
	u64(1e8),
	u64(1e9),
	u64(1e10),
	u64(1e11),
	u64(1e12),
	u64(1e13),
	u64(1e14),
	u64(1e15),
	u64(1e16),
	u64(1e17)
	// We only need to find the length of at most 17 digit numbers.
]

pow5_split_32 = [ 
	1152921504606846976, 1441151880758558720, 1801439850948198400, 2251799813685248000,
	1407374883553280000, 1759218604441600000, 2199023255552000000, 1374389534720000000,
	1717986918400000000, 2147483648000000000, 1342177280000000000, 1677721600000000000,
	2097152000000000000, 1310720000000000000, 1638400000000000000, 2048000000000000000,
	1280000000000000000, 1600000000000000000, 2000000000000000000, 1250000000000000000,
	1562500000000000000, 1953125000000000000, 1220703125000000000, 1525878906250000000,
	1907348632812500000, 1192092895507812500, 1490116119384765625, 1862645149230957031,
	1164153218269348144, 1455191522836685180, 1818989403545856475, 2273736754432320594,
	1421085471520200371, 1776356839400250464, 2220446049250313080, 1387778780781445675,
	1734723475976807094, 2168404344971008868, 1355252715606880542, 1694065894508600678,
	2117582368135750847, 1323488980084844279, 1654361225106055349, 2067951531382569187,
	1292469707114105741, 1615587133892632177, 2019483917365790221
]

pow5_inv_split_32 = [
	576460752303423489, 461168601842738791, 368934881474191033, 295147905179352826,
	472236648286964522, 377789318629571618, 302231454903657294, 483570327845851670,
	386856262276681336, 309485009821345069, 495176015714152110, 396140812571321688,
	316912650057057351, 507060240091291761, 405648192073033409, 324518553658426727,
	519229685853482763, 415383748682786211, 332306998946228969, 531691198313966350,
	425352958651173080, 340282366920938464, 544451787073501542, 435561429658801234,
	348449143727040987, 557518629963265579, 446014903970612463, 356811923176489971,
	570899077082383953, 456719261665907162, 365375409332725730
]

pow5_split_64 =[
	Uint128{u64(0), 72057594037927936},
	Uint128{u64(0), 90071992547409920},
	Uint128{u64(0), 112589990684262400},
	Uint128{u64(0), 140737488355328000},
	Uint128{u64(0), 87960930222080000},
	Uint128{u64(0), 109951162777600000},
	Uint128{u64(0), 137438953472000000},
	Uint128{u64(0), 85899345920000000},
	Uint128{u64(0), 107374182400000000},
	Uint128{u64(0), 134217728000000000},
	Uint128{u64(0), 83886080000000000},
	Uint128{u64(0), 104857600000000000},
	Uint128{u64(0), 131072000000000000},
	Uint128{u64(0), 81920000000000000},
	Uint128{u64(0), 102400000000000000},
	Uint128{u64(0), 128000000000000000},
	Uint128{u64(0), 80000000000000000},
	Uint128{u64(0), 100000000000000000},
	Uint128{u64(0), 125000000000000000},
	Uint128{u64(0), 78125000000000000},
	Uint128{u64(0), 97656250000000000},
	Uint128{u64(0), 122070312500000000},
	Uint128{u64(0), 76293945312500000},
	Uint128{u64(0), 95367431640625000},
	Uint128{u64(0), 119209289550781250},
	Uint128{4611686018427387904, 74505805969238281},
	Uint128{10376293541461622784, 93132257461547851},
	Uint128{8358680908399640576, 116415321826934814},
	Uint128{612489549322387456, 72759576141834259},
	Uint128{14600669991935148032, 90949470177292823},
	Uint128{13639151471491547136, 113686837721616029},
	Uint128{3213881284082270208, 142108547152020037},
	Uint128{4314518811765112832, 88817841970012523},
	Uint128{781462496279003136, 111022302462515654},
	Uint128{10200200157203529728, 138777878078144567},
	Uint128{13292654125893287936, 86736173798840354},
	Uint128{7392445620511834112, 108420217248550443},
	Uint128{4628871007212404736, 135525271560688054},
	Uint128{16728102434789916672, 84703294725430033},
	Uint128{7075069988205232128, 105879118406787542},
	Uint128{18067209522111315968, 132348898008484427},
	Uint128{8986162942105878528, 82718061255302767},
	Uint128{6621017659204960256, 103397576569128459},
	Uint128{3664586055578812416, 129246970711410574},
	Uint128{16125424340018921472, 80779356694631608},
	Uint128{1710036351314100224, 100974195868289511},
	Uint128{15972603494424788992, 126217744835361888},
	Uint128{9982877184015493120, 78886090522101180},
	Uint128{12478596480019366400, 98607613152626475},
	Uint128{10986559581596820096, 123259516440783094},
	Uint128{2254913720070624656, 77037197775489434},
	Uint128{12042014186943056628, 96296497219361792},
	Uint128{15052517733678820785, 120370621524202240},
	Uint128{9407823583549262990, 75231638452626400},
	Uint128{11759779479436578738, 94039548065783000},
	Uint128{14699724349295723422, 117549435082228750},
	Uint128{4575641699882439235, 73468396926392969},
	Uint128{10331238143280436948, 91835496157991211},
	Uint128{8302361660673158281, 114794370197489014},
	Uint128{1154580038986672043, 143492962746861268},
	Uint128{9944984561221445835, 89683101716788292},
	Uint128{12431230701526807293, 112103877145985365},
	Uint128{1703980321626345405, 140129846432481707},
	Uint128{17205888765512323542, 87581154020301066},
	Uint128{12283988920035628619, 109476442525376333},
	Uint128{1519928094762372062, 136845553156720417},
	Uint128{12479170105294952299, 85528470722950260},
	Uint128{15598962631618690374, 106910588403687825},
	Uint128{5663645234241199255, 133638235504609782},
	Uint128{17374836326682913246, 83523897190381113},
	Uint128{7883487353071477846, 104404871487976392},
	Uint128{9854359191339347308, 130506089359970490},
	Uint128{10770660513014479971, 81566305849981556},
	Uint128{13463325641268099964, 101957882312476945},
	Uint128{2994098996302961243, 127447352890596182},
	Uint128{15706369927971514489, 79654595556622613},
	Uint128{5797904354682229399, 99568244445778267},
	Uint128{2635694424925398845, 124460305557222834},
	Uint128{6258995034005762182, 77787690973264271},
	Uint128{3212057774079814824, 97234613716580339},
	Uint128{17850130272881932242, 121543267145725423},
	Uint128{18073860448192289507, 75964541966078389},
	Uint128{8757267504958198172, 94955677457597987},
	Uint128{6334898362770359811, 118694596821997484},
	Uint128{13182683513586250689, 74184123013748427},
	Uint128{11866668373555425458, 92730153767185534},
	Uint128{5609963430089506015, 115912692208981918},
	Uint128{17341285199088104971, 72445432630613698},
	Uint128{12453234462005355406, 90556790788267123},
	Uint128{10954857059079306353, 113195988485333904},
	Uint128{13693571323849132942, 141494985606667380},
	Uint128{17781854114260483896, 88434366004167112},
	Uint128{3780573569116053255, 110542957505208891},
	Uint128{114030942967678664, 138178696881511114},
	Uint128{4682955357782187069, 86361685550944446},
	Uint128{15077066234082509644, 107952106938680557},
	Uint128{5011274737320973344, 134940133673350697},
	Uint128{14661261756894078100, 84337583545844185},
	Uint128{4491519140835433913, 105421979432305232},
	Uint128{5614398926044292391, 131777474290381540},
	Uint128{12732371365632458552, 82360921431488462},
	Uint128{6692092170185797382, 102951151789360578},
	Uint128{17588487249587022536, 128688939736700722},
	Uint128{15604490549419276989, 80430587335437951},
	Uint128{14893927168346708332, 100538234169297439},
	Uint128{14005722942005997511, 125672792711621799},
	Uint128{15671105866394830300, 78545495444763624},
	Uint128{1142138259283986260, 98181869305954531},
	Uint128{15262730879387146537, 122727336632443163},
	Uint128{7233363790403272633, 76704585395276977},
	Uint128{13653390756431478696, 95880731744096221},
	Uint128{3231680390257184658, 119850914680120277},
	Uint128{4325643253124434363, 74906821675075173},
	Uint128{10018740084832930858, 93633527093843966},
	Uint128{3300053069186387764, 117041908867304958},
	Uint128{15897591223523656064, 73151193042065598},
	Uint128{10648616992549794273, 91438991302581998},
	Uint128{4087399203832467033, 114298739128227498},
	Uint128{14332621041645359599, 142873423910284372},
	Uint128{18181260187883125557, 89295889943927732},
	Uint128{4279831161144355331, 111619862429909666},
	Uint128{14573160988285219972, 139524828037387082},
	Uint128{13719911636105650386, 87203017523366926},
	Uint128{7926517508277287175, 109003771904208658},
	Uint128{684774848491833161, 136254714880260823},
	Uint128{7345513307948477581, 85159196800163014},
	Uint128{18405263671790372785, 106448996000203767},
	Uint128{18394893571310578077, 133061245000254709},
	Uint128{13802651491282805250, 83163278125159193},
	Uint128{3418256308821342851, 103954097656448992},
	Uint128{4272820386026678563, 129942622070561240},
	Uint128{2670512741266674102, 81214138794100775},
	Uint128{17173198981865506339, 101517673492625968},
	Uint128{3019754653622331308, 126897091865782461},
	Uint128{4193189667727651020, 79310682416114038},
	Uint128{14464859121514339583, 99138353020142547},
	Uint128{13469387883465536574, 123922941275178184},
	Uint128{8418367427165960359, 77451838296986365},
	Uint128{15134645302384838353, 96814797871232956},
	Uint128{471562554271496325, 121018497339041196},
	Uint128{9518098633274461011, 75636560836900747},
	Uint128{7285937273165688360, 94545701046125934},
	Uint128{18330793628311886258, 118182126307657417},
	Uint128{4539216990053847055, 73863828942285886},
	Uint128{14897393274422084627, 92329786177857357},
	Uint128{4786683537745442072, 115412232722321697},
	Uint128{14520892257159371055, 72132645451451060},
	Uint128{18151115321449213818, 90165806814313825},
	Uint128{8853836096529353561, 112707258517892282},
	Uint128{1843923083806916143, 140884073147365353},
	Uint128{12681666973447792349, 88052545717103345},
	Uint128{2017025661527576725, 110065682146379182},
	Uint128{11744654113764246714, 137582102682973977},
	Uint128{422879793461572340, 85988814176858736},
	Uint128{528599741826965425, 107486017721073420},
	Uint128{660749677283706782, 134357522151341775},
	Uint128{7330497575943398595, 83973451344588609},
	Uint128{13774807988356636147, 104966814180735761},
	Uint128{3383451930163631472, 131208517725919702},
	Uint128{15949715511634433382, 82005323578699813},
	Uint128{6102086334260878016, 102506654473374767},
	Uint128{3015921899398709616, 128133318091718459},
	Uint128{18025852251620051174, 80083323807324036},
	Uint128{4085571240815512351, 100104154759155046},
	Uint128{14330336087874166247, 125130193448943807},
	Uint128{15873989082562435760, 78206370905589879},
	Uint128{15230800334775656796, 97757963631987349},
	Uint128{5203442363187407284, 122197454539984187},
	Uint128{946308467778435600, 76373409087490117},
	Uint128{5794571603150432404, 95466761359362646},
	Uint128{16466586540792816313, 119333451699203307},
	Uint128{7985773578781816244, 74583407312002067},
	Uint128{5370530955049882401, 93229259140002584},
	Uint128{6713163693812353001, 116536573925003230},
	Uint128{18030785363914884337, 72835358703127018},
	Uint128{13315109668038829614, 91044198378908773},
	Uint128{2808829029766373305, 113805247973635967},
	Uint128{17346094342490130344, 142256559967044958},
	Uint128{6229622945628943561, 88910349979403099},
	Uint128{3175342663608791547, 111137937474253874},
	Uint128{13192550366365765242, 138922421842817342},
	Uint128{3633657960551215372, 86826513651760839},
	Uint128{18377130505971182927, 108533142064701048},
	Uint128{4524669058754427043, 135666427580876311},
	Uint128{9745447189362598758, 84791517238047694},
	Uint128{2958436949848472639, 105989396547559618},
	Uint128{12921418224165366607, 132486745684449522},
	Uint128{12687572408530742033, 82804216052780951},
	Uint128{11247779492236039638, 103505270065976189},
	Uint128{224666310012885835, 129381587582470237},
	Uint128{2446259452971747599, 80863492239043898},
	Uint128{12281196353069460307, 101079365298804872},
	Uint128{15351495441336825384, 126349206623506090},
	Uint128{14206370669262903769, 78968254139691306},
	Uint128{8534591299723853903, 98710317674614133},
	Uint128{15279925143082205283, 123387897093267666},
	Uint128{14161639232853766206, 77117435683292291},
	Uint128{13090363022639819853, 96396794604115364},
	Uint128{16362953778299774816, 120495993255144205},
	Uint128{12532689120651053212, 75309995784465128},
	Uint128{15665861400813816515, 94137494730581410},
	Uint128{10358954714162494836, 117671868413226763},
	Uint128{4168503687137865320, 73544917758266727},
	Uint128{598943590494943747, 91931147197833409},
	Uint128{5360365506546067587, 114913933997291761},
	Uint128{11312142901609972388, 143642417496614701},
	Uint128{9375932322719926695, 89776510935384188},
	Uint128{11719915403399908368, 112220638669230235},
	Uint128{10038208235822497557, 140275798336537794},
	Uint128{10885566165816448877, 87672373960336121},
	Uint128{18218643725697949000, 109590467450420151},
	Uint128{18161618638695048346, 136988084313025189},
	Uint128{13656854658398099168, 85617552695640743},
	Uint128{12459382304570236056, 107021940869550929},
	Uint128{1739169825430631358, 133777426086938662},
	Uint128{14922039196176308311, 83610891304336663},
	Uint128{14040862976792997485, 104513614130420829},
	Uint128{3716020665709083144, 130642017663026037},
	Uint128{4628355925281870917, 81651261039391273},
	Uint128{10397130925029726550, 102064076299239091},
	Uint128{8384727637859770284, 127580095374048864},
	Uint128{5240454773662356427, 79737559608780540},
	Uint128{6550568467077945534, 99671949510975675},
	Uint128{3576524565420044014, 124589936888719594},
	Uint128{6847013871814915412, 77868710555449746},
	Uint128{17782139376623420074, 97335888194312182},
	Uint128{13004302183924499284, 121669860242890228},
	Uint128{17351060901807587860, 76043662651806392},
	Uint128{3242082053549933210, 95054578314757991},
	Uint128{17887660622219580224, 118818222893447488},
	Uint128{11179787888887237640, 74261389308404680},
	Uint128{13974734861109047050, 92826736635505850},
	Uint128{8245046539531533005, 116033420794382313},
	Uint128{16682369133275677888, 72520887996488945},
	Uint128{7017903361312433648, 90651109995611182},
	Uint128{17995751238495317868, 113313887494513977},
	Uint128{8659630992836983623, 141642359368142472},
	Uint128{5412269370523114764, 88526474605089045},
	Uint128{11377022731581281359, 110658093256361306},
	Uint128{4997906377621825891, 138322616570451633},
	Uint128{14652906532082110942, 86451635356532270},
	Uint128{9092761128247862869, 108064544195665338},
	Uint128{2142579373455052779, 135080680244581673},
	Uint128{12868327154477877747, 84425425152863545},
	Uint128{2250350887815183471, 105531781441079432},
	Uint128{2812938609768979339, 131914726801349290},
	Uint128{6369772649532999991, 82446704250843306},
	Uint128{17185587848771025797, 103058380313554132},
	Uint128{3035240737254230630, 128822975391942666},
	Uint128{6508711479211282048, 80514359619964166},
	Uint128{17359261385868878368, 100642949524955207},
	Uint128{17087390713908710056, 125803686906194009},
	Uint128{3762090168551861929, 78627304316371256},
	Uint128{4702612710689827411, 98284130395464070},
	Uint128{15101637925217060072, 122855162994330087},
	Uint128{16356052730901744401, 76784476871456304},
	Uint128{1998321839917628885, 95980596089320381},
	Uint128{7109588318324424010, 119975745111650476},
	Uint128{13666864735807540814, 74984840694781547},
	Uint128{12471894901332038114, 93731050868476934},
	Uint128{6366496589810271835, 117163813585596168},
	Uint128{3979060368631419896, 73227383490997605},
	Uint128{9585511479216662775, 91534229363747006},
	Uint128{2758517312166052660, 114417786704683758},
	Uint128{12671518677062341634, 143022233380854697},
	Uint128{1002170145522881665, 89388895863034186},
	Uint128{10476084718758377889, 111736119828792732},
	Uint128{13095105898447972362, 139670149785990915},
	Uint128{5878598177316288774, 87293843616244322},
	Uint128{16571619758500136775, 109117304520305402},
	Uint128{11491152661270395161, 136396630650381753},
	Uint128{264441385652915120, 85247894156488596},
	Uint128{330551732066143900, 106559867695610745},
	Uint128{5024875683510067779, 133199834619513431},
	Uint128{10058076329834874218, 83249896637195894},
	Uint128{3349223375438816964, 104062370796494868},
	Uint128{4186529219298521205, 130077963495618585},
	Uint128{14145795808130045513, 81298727184761615},
	Uint128{13070558741735168987, 101623408980952019},
	Uint128{11726512408741573330, 127029261226190024},
	Uint128{7329070255463483331, 79393288266368765},
	Uint128{13773023837756742068, 99241610332960956},
	Uint128{17216279797195927585, 124052012916201195},
	Uint128{8454331864033760789, 77532508072625747},
	Uint128{5956228811614813082, 96915635090782184},
	Uint128{7445286014518516353, 121144543863477730},
	Uint128{9264989777501460624, 75715339914673581},
	Uint128{16192923240304213684, 94644174893341976},
	Uint128{1794409976670715490, 118305218616677471},
	Uint128{8039035263060279037, 73940761635423419},
	Uint128{5437108060397960892, 92425952044279274},
	Uint128{16019757112352226923, 115532440055349092},
	Uint128{788976158365366019, 72207775034593183},
	Uint128{14821278253238871236, 90259718793241478},
	Uint128{9303225779693813237, 112824648491551848},
	Uint128{11629032224617266546, 141030810614439810},
	Uint128{11879831158813179495, 88144256634024881},
	Uint128{1014730893234310657, 110180320792531102},
	Uint128{10491785653397664129, 137725400990663877},
	Uint128{8863209042587234033, 86078375619164923},
	Uint128{6467325284806654637, 107597969523956154},
	Uint128{17307528642863094104, 134497461904945192},
	Uint128{10817205401789433815, 84060913690590745},
	Uint128{18133192770664180173, 105076142113238431},
	Uint128{18054804944902837312, 131345177641548039},
	Uint128{18201782118205355176, 82090736025967524},
	Uint128{4305483574047142354, 102613420032459406},
	Uint128{14605226504413703751, 128266775040574257},
	Uint128{2210737537617482988, 80166734400358911},
	Uint128{16598479977304017447, 100208418000448638},
	Uint128{11524727934775246001, 125260522500560798},
	Uint128{2591268940807140847, 78287826562850499},
	Uint128{17074144231291089770, 97859783203563123},
	Uint128{16730994270686474309, 122324729004453904},
	Uint128{10456871419179046443, 76452955627783690},
	Uint128{3847717237119032246, 95566194534729613},
	Uint128{9421332564826178211, 119457743168412016},
	Uint128{5888332853016361382, 74661089480257510},
	Uint128{16583788103125227536, 93326361850321887},
	Uint128{16118049110479146516, 116657952312902359},
	Uint128{16991309721690548428, 72911220195563974},
	Uint128{12015765115258409727, 91139025244454968},
	Uint128{15019706394073012159, 113923781555568710},
	Uint128{9551260955736489391, 142404726944460888},
	Uint128{5969538097335305869, 89002954340288055},
	Uint128{2850236603241744433, 111253692925360069}
]

pow5_inv_split_64 = [
	Uint128{u64(1), 288230376151711744},
	Uint128{3689348814741910324, 230584300921369395},
	Uint128{2951479051793528259, 184467440737095516},
	Uint128{17118578500402463900, 147573952589676412},
	Uint128{12632330341676300947, 236118324143482260},
	Uint128{10105864273341040758, 188894659314785808},
	Uint128{15463389048156653253, 151115727451828646},
	Uint128{17362724847566824558, 241785163922925834},
	Uint128{17579528692795369969, 193428131138340667},
	Uint128{6684925324752475329, 154742504910672534},
	Uint128{18074578149087781173, 247588007857076054},
	Uint128{18149011334012135262, 198070406285660843},
	Uint128{3451162622983977240, 158456325028528675},
	Uint128{5521860196774363583, 253530120045645880},
	Uint128{4417488157419490867, 202824096036516704},
	Uint128{7223339340677503017, 162259276829213363},
	Uint128{7867994130342094503, 259614842926741381},
	Uint128{2605046489531765280, 207691874341393105},
	Uint128{2084037191625412224, 166153499473114484},
	Uint128{10713157136084480204, 265845599156983174},
	Uint128{12259874523609494487, 212676479325586539},
	Uint128{13497248433629505913, 170141183460469231},
	Uint128{14216899864323388813, 272225893536750770},
	Uint128{11373519891458711051, 217780714829400616},
	Uint128{5409467098425058518, 174224571863520493},
	Uint128{4965798542738183305, 278759314981632789},
	Uint128{7661987648932456967, 223007451985306231},
	Uint128{2440241304404055250, 178405961588244985},
	Uint128{3904386087046488400, 285449538541191976},
	Uint128{17880904128604832013, 228359630832953580},
	Uint128{14304723302883865611, 182687704666362864},
	Uint128{15133127457049002812, 146150163733090291},
	Uint128{16834306301794583852, 233840261972944466},
	Uint128{9778096226693756759, 187072209578355573},
	Uint128{15201174610838826053, 149657767662684458},
	Uint128{2185786488890659746, 239452428260295134},
	Uint128{5437978005854438120, 191561942608236107},
	Uint128{15418428848909281466, 153249554086588885},
	Uint128{6222742084545298729, 245199286538542217},
	Uint128{16046240111861969953, 196159429230833773},
	Uint128{1768945645263844993, 156927543384667019},
	Uint128{10209010661905972635, 251084069415467230},
	Uint128{8167208529524778108, 200867255532373784},
	Uint128{10223115638361732810, 160693804425899027},
	Uint128{1599589762411131202, 257110087081438444},
	Uint128{4969020624670815285, 205688069665150755},
	Uint128{3975216499736652228, 164550455732120604},
	Uint128{13739044029062464211, 263280729171392966},
	Uint128{7301886408508061046, 210624583337114373},
	Uint128{13220206756290269483, 168499666669691498},
	Uint128{17462981995322520850, 269599466671506397},
	Uint128{6591687966774196033, 215679573337205118},
	Uint128{12652048002903177473, 172543658669764094},
	Uint128{9175230360419352987, 276069853871622551},
	Uint128{3650835473593572067, 220855883097298041},
	Uint128{17678063637842498946, 176684706477838432},
	Uint128{13527506561580357021, 282695530364541492},
	Uint128{3443307619780464970, 226156424291633194},
	Uint128{6443994910566282300, 180925139433306555},
	Uint128{5155195928453025840, 144740111546645244},
	Uint128{15627011115008661990, 231584178474632390},
	Uint128{12501608892006929592, 185267342779705912},
	Uint128{2622589484121723027, 148213874223764730},
	Uint128{4196143174594756843, 237142198758023568},
	Uint128{10735612169159626121, 189713759006418854},
	Uint128{12277838550069611220, 151771007205135083},
	Uint128{15955192865369467629, 242833611528216133},
	Uint128{1696107848069843133, 194266889222572907},
	Uint128{12424932722681605476, 155413511378058325},
	Uint128{1433148282581017146, 248661618204893321},
	Uint128{15903913885032455010, 198929294563914656},
	Uint128{9033782293284053685, 159143435651131725},
	Uint128{14454051669254485895, 254629497041810760},
	Uint128{11563241335403588716, 203703597633448608},
	Uint128{16629290697806691620, 162962878106758886},
	Uint128{781423413297334329, 260740604970814219},
	Uint128{4314487545379777786, 208592483976651375},
	Uint128{3451590036303822229, 166873987181321100},
	Uint128{5522544058086115566, 266998379490113760},
	Uint128{4418035246468892453, 213598703592091008},
	Uint128{10913125826658934609, 170878962873672806},
	Uint128{10082303693170474728, 273406340597876490},
	Uint128{8065842954536379782, 218725072478301192},
	Uint128{17520720807854834795, 174980057982640953},
	Uint128{5897060404116273733, 279968092772225526},
	Uint128{1028299508551108663, 223974474217780421},
	Uint128{15580034865808528224, 179179579374224336},
	Uint128{17549358155809824511, 286687326998758938},
	Uint128{2971440080422128639, 229349861599007151},
	Uint128{17134547323305344204, 183479889279205720},
	Uint128{13707637858644275364, 146783911423364576},
	Uint128{14553522944347019935, 234854258277383322},
	Uint128{4264120725993795302, 187883406621906658},
	Uint128{10789994210278856888, 150306725297525326},
	Uint128{9885293106962350374, 240490760476040522},
	Uint128{529536856086059653, 192392608380832418},
	Uint128{7802327114352668369, 153914086704665934},
	Uint128{1415676938738538420, 246262538727465495},
	Uint128{1132541550990830736, 197010030981972396},
	Uint128{15663428499760305882, 157608024785577916},
	Uint128{17682787970132668764, 252172839656924666},
	Uint128{10456881561364224688, 201738271725539733},
	Uint128{15744202878575200397, 161390617380431786},
	Uint128{17812026976236499989, 258224987808690858},
	Uint128{3181575136763469022, 206579990246952687},
	Uint128{13613306553636506187, 165263992197562149},
	Uint128{10713244041592678929, 264422387516099439},
	Uint128{12259944048016053467, 211537910012879551},
	Uint128{6118606423670932450, 169230328010303641},
	Uint128{2411072648389671274, 270768524816485826},
	Uint128{16686253377679378312, 216614819853188660},
	Uint128{13349002702143502650, 173291855882550928},
	Uint128{17669055508687693916, 277266969412081485},
	Uint128{14135244406950155133, 221813575529665188},
	Uint128{240149081334393137, 177450860423732151},
	Uint128{11452284974360759988, 283921376677971441},
	Uint128{5472479164746697667, 227137101342377153},
	Uint128{11756680961281178780, 181709681073901722},
	Uint128{2026647139541122378, 145367744859121378},
	Uint128{18000030682233437097, 232588391774594204},
	Uint128{18089373360528660001, 186070713419675363},
	Uint128{3403452244197197031, 148856570735740291},
	Uint128{16513570034941246220, 238170513177184465},
	Uint128{13210856027952996976, 190536410541747572},
	Uint128{3189987192878576934, 152429128433398058},
	Uint128{1414630693863812771, 243886605493436893},
	Uint128{8510402184574870864, 195109284394749514},
	Uint128{10497670562401807014, 156087427515799611},
	Uint128{9417575270359070576, 249739884025279378},
	Uint128{14912757845771077107, 199791907220223502},
	Uint128{4551508647133041040, 159833525776178802},
	Uint128{10971762650154775986, 255733641241886083},
	Uint128{16156107749607641435, 204586912993508866},
	Uint128{9235537384944202825, 163669530394807093},
	Uint128{11087511001168814197, 261871248631691349},
	Uint128{12559357615676961681, 209496998905353079},
	Uint128{13736834907283479668, 167597599124282463},
	Uint128{18289587036911657145, 268156158598851941},
	Uint128{10942320814787415393, 214524926879081553},
	Uint128{16132554281313752961, 171619941503265242},
	Uint128{11054691591134363444, 274591906405224388},
	Uint128{16222450902391311402, 219673525124179510},
	Uint128{12977960721913049122, 175738820099343608},
	Uint128{17075388340318968271, 281182112158949773},
	Uint128{2592264228029443648, 224945689727159819},
	Uint128{5763160197165465241, 179956551781727855},
	Uint128{9221056315464744386, 287930482850764568},
	Uint128{14755542681855616155, 230344386280611654},
	Uint128{15493782960226403247, 184275509024489323},
	Uint128{1326979923955391628, 147420407219591459},
	Uint128{9501865507812447252, 235872651551346334},
	Uint128{11290841220991868125, 188698121241077067},
	Uint128{1653975347309673853, 150958496992861654},
	Uint128{10025058185179298811, 241533595188578646},
	Uint128{4330697733401528726, 193226876150862917},
	Uint128{14532604630946953951, 154581500920690333},
	Uint128{1116074521063664381, 247330401473104534},
	Uint128{4582208431592841828, 197864321178483627},
	Uint128{14733813189500004432, 158291456942786901},
	Uint128{16195403473716186445, 253266331108459042},
	Uint128{5577625149489128510, 202613064886767234},
	Uint128{8151448934333213131, 162090451909413787},
	Uint128{16731667109675051333, 259344723055062059},
	Uint128{17074682502481951390, 207475778444049647},
	Uint128{6281048372501740465, 165980622755239718},
	Uint128{6360328581260874421, 265568996408383549},
	Uint128{8777611679750609860, 212455197126706839},
	Uint128{10711438158542398211, 169964157701365471},
	Uint128{9759603424184016492, 271942652322184754},
	Uint128{11497031554089123517, 217554121857747803},
	Uint128{16576322872755119460, 174043297486198242},
	Uint128{11764721337440549842, 278469275977917188},
	Uint128{16790474699436260520, 222775420782333750},
	Uint128{13432379759549008416, 178220336625867000},
	Uint128{3045063541568861850, 285152538601387201},
	Uint128{17193446092222730773, 228122030881109760},
	Uint128{13754756873778184618, 182497624704887808},
	Uint128{18382503128506368341, 145998099763910246},
	Uint128{3586563302416817083, 233596959622256395},
	Uint128{2869250641933453667, 186877567697805116},
	Uint128{17052795772514404226, 149502054158244092},
	Uint128{12527077977055405469, 239203286653190548},
	Uint128{17400360011128145022, 191362629322552438},
	Uint128{2852241564676785048, 153090103458041951},
	Uint128{15631632947708587046, 244944165532867121},
	Uint128{8815957543424959314, 195955332426293697},
	Uint128{18120812478965698421, 156764265941034957},
	Uint128{14235904707377476180, 250822825505655932},
	Uint128{4010026136418160298, 200658260404524746},
	Uint128{17965416168102169531, 160526608323619796},
	Uint128{2919224165770098987, 256842573317791675},
	Uint128{2335379332616079190, 205474058654233340},
	Uint128{1868303466092863352, 164379246923386672},
	Uint128{6678634360490491686, 263006795077418675},
	Uint128{5342907488392393349, 210405436061934940},
	Uint128{4274325990713914679, 168324348849547952},
	Uint128{10528270399884173809, 269318958159276723},
	Uint128{15801313949391159694, 215455166527421378},
	Uint128{1573004715287196786, 172364133221937103},
	Uint128{17274202803427156150, 275782613155099364},
	Uint128{17508711057483635243, 220626090524079491},
	Uint128{10317620031244997871, 176500872419263593},
	Uint128{12818843235250086271, 282401395870821749},
	Uint128{13944423402941979340, 225921116696657399},
	Uint128{14844887537095493795, 180736893357325919},
	Uint128{15565258844418305359, 144589514685860735},
	Uint128{6457670077359736959, 231343223497377177},
	Uint128{16234182506113520537, 185074578797901741},
	Uint128{9297997190148906106, 148059663038321393},
	Uint128{11187446689496339446, 236895460861314229},
	Uint128{12639306166338981880, 189516368689051383},
	Uint128{17490142562555006151, 151613094951241106},
	Uint128{2158786396894637579, 242580951921985771},
	Uint128{16484424376483351356, 194064761537588616},
	Uint128{9498190686444770762, 155251809230070893},
	Uint128{11507756283569722895, 248402894768113429},
	Uint128{12895553841597688639, 198722315814490743},
	Uint128{17695140702761971558, 158977852651592594},
	Uint128{17244178680193423523, 254364564242548151},
	Uint128{10105994129412828495, 203491651394038521},
	Uint128{4395446488788352473, 162793321115230817},
	Uint128{10722063196803274280, 260469313784369307},
	Uint128{1198952927958798777, 208375451027495446},
	Uint128{15716557601334680315, 166700360821996356},
	Uint128{17767794532651667857, 266720577315194170},
	Uint128{14214235626121334286, 213376461852155336},
	Uint128{7682039686155157106, 170701169481724269},
	Uint128{1223217053622520399, 273121871170758831},
	Uint128{15735968901865657612, 218497496936607064},
	Uint128{16278123936234436413, 174797997549285651},
	Uint128{219556594781725998, 279676796078857043},
	Uint128{7554342905309201445, 223741436863085634},
	Uint128{9732823138989271479, 178993149490468507},
	Uint128{815121763415193074, 286389039184749612},
	Uint128{11720143854957885429, 229111231347799689},
	Uint128{13065463898708218666, 183288985078239751},
	Uint128{6763022304224664610, 146631188062591801},
	Uint128{3442138057275642729, 234609900900146882},
	Uint128{13821756890046245153, 187687920720117505},
	Uint128{11057405512036996122, 150150336576094004},
	Uint128{6623802375033462826, 240240538521750407},
	Uint128{16367088344252501231, 192192430817400325},
	Uint128{13093670675402000985, 153753944653920260},
	Uint128{2503129006933649959, 246006311446272417},
	Uint128{13070549649772650937, 196805049157017933},
	Uint128{17835137349301941396, 157444039325614346},
	Uint128{2710778055689733971, 251910462920982955},
	Uint128{2168622444551787177, 201528370336786364},
	Uint128{5424246770383340065, 161222696269429091},
	Uint128{1300097203129523457, 257956314031086546},
	Uint128{15797473021471260058, 206365051224869236},
	Uint128{8948629602435097724, 165092040979895389},
	Uint128{3249760919670425388, 264147265567832623},
	Uint128{9978506365220160957, 211317812454266098},
	Uint128{15361502721659949412, 169054249963412878},
	Uint128{2442311466204457120, 270486799941460606},
	Uint128{16711244431931206989, 216389439953168484},
	Uint128{17058344360286875914, 173111551962534787},
	Uint128{12535955717491360170, 276978483140055660},
	Uint128{10028764573993088136, 221582786512044528},
	Uint128{15401709288678291155, 177266229209635622},
	Uint128{9885339602917624555, 283625966735416996},
	Uint128{4218922867592189321, 226900773388333597},
	Uint128{14443184738299482427, 181520618710666877},
	Uint128{4175850161155765295, 145216494968533502},
	Uint128{10370709072591134795, 232346391949653603},
	Uint128{15675264887556728482, 185877113559722882},
	Uint128{5161514280561562140, 148701690847778306},
	Uint128{879725219414678777, 237922705356445290},
	Uint128{703780175531743021, 190338164285156232},
	Uint128{11631070584651125387, 152270531428124985},
	Uint128{162968861732249003, 243632850284999977},
	Uint128{11198421533611530172, 194906280227999981},
	Uint128{5269388412147313814, 155925024182399985},
	Uint128{8431021459435702103, 249480038691839976},
	Uint128{3055468352806651359, 199584030953471981},
	Uint128{17201769941212962380, 159667224762777584},
	Uint128{16454785461715008838, 255467559620444135},
	Uint128{13163828369372007071, 204374047696355308},
	Uint128{17909760324981426303, 163499238157084246},
	Uint128{2830174816776909822, 261598781051334795},
	Uint128{2264139853421527858, 209279024841067836},
	Uint128{16568707141704863579, 167423219872854268},
	Uint128{4373838538276319787, 267877151796566830},
	Uint128{3499070830621055830, 214301721437253464},
	Uint128{6488605479238754987, 171441377149802771},
	Uint128{3003071137298187333, 274306203439684434},
	Uint128{6091805724580460189, 219444962751747547},
	Uint128{15941491023890099121, 175555970201398037},
	Uint128{10748990379256517301, 280889552322236860},
	Uint128{8599192303405213841, 224711641857789488},
	Uint128{14258051472207991719, 179769313486231590}
]
)