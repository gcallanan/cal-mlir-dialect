module {
  cal.actor @__fanout_i16_5()
    in_names ["in"]
    out_names ["out0", "out1", "out2", "out3", "out4"]
    ports_in (
      %arg0: !fifo.output_port<i16>
    )
    ports_out (
      %arg1: !fifo.input_port<i16>, 
      %arg2: !fifo.input_port<i16>, 
      %arg3: !fifo.input_port<i16>, 
      %arg4: !fifo.input_port<i16>, 
      %arg5: !fifo.input_port<i16>
    )
  {
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<i16>) : i16
      fifo.push(%arg1 : !fifo.input_port<i16>, %0 : i16)
      fifo.push(%arg2 : !fifo.input_port<i16>, %0 : i16)
      fifo.push(%arg3 : !fifo.input_port<i16>, %0 : i16)
      fifo.push(%arg4 : !fifo.input_port<i16>, %0 : i16)
      fifo.push(%arg5 : !fifo.input_port<i16>, %0 : i16)
    }
    
  }
  
  memref.global "private" constant @__cmr_0 : memref<3xi8> = dense<[0, 1, 1]>
  memref.global "private" constant @__cmr_1 : memref<3xi8> = dense<[2, 3, 3]>
  memref.global "private" constant @__cmr_2 : memref<3xi32> = dense<[4, 1, 1]>
  memref.global "private" constant @__cmr_3 : memref<3867xi8> = dense<"0x6AD8FFE000104A46494600010101004800480000FFDB004300100B0C0E0C0A100E0D0E1211101318281A181616183123251D283A333D3C3933383740485C4E404457453738506D51575F626768673E4D71797064785C656763FFDB0043011112121815182F1A1A2F634238426363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363FFC0001108009000B003012200021101031101FFC4001F0000010501010101010100000000000000000102030405060708090A0BFFC4001F0100030101010101010101010000000000000102030405060708090A0BFFC400B5100002010303020403050504040000017D01020300041105122131410613516107227114328191A1082342B1C11552D1F02433627282090A161718191A25262728292A3435363738393A434445464748494A535455565758595A636465666768696A737475767778797A838485868788898A92939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC400B51100020102040403040705040400010277000102031104052131061241510761711322328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728292A35363738393A434445464748494A535455565758595A636465666768696A737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00DBD1649A6D1ED7CA9648D7C8503EA0638F6ABEC970738BB90647031D0D666897905B68366247C1F2C70066A74BF9A6918430E531F2B1FEB49CDA33F6317A97BF7C324DCB6370383D07A8A89EF016DB02195BD4741F8D4420791B372E5FD00E145588D40E8001E82A5C9B348C147622303CA41B872C3FB8BC2FFF005EA655DAB8000C7A7414923051924003A9354E7D4A18C7C9F39F5CE054945E1C5579F50861C8DDBD8765FF001ACECDF5F1F95488FD5BE55FFEBD5987498970D3B194FA630A3F0A7A815CDEDD5E12B6E8707B27F5352C3A516F9AE643EBB23FF1AD48E200055501454EAA17EB4D215CAF6F6C90C7B618C22D3DA127918CFD6A7A2AAC0519E12D1323A821863079158B2C53E9D38962398CF193D3E87FC6BA8F6AA5756E0AB7195230454B41722B5B94B98B729E4751DC53D802483E958B3C32E9D389A1398CF4CF6F63FE35AB697497511653861F794F515232B6E6B193775818FCCA3AA1F51ED57F2B2286520823208EF51CAB95C119AA7148D62D86C9818F4FEE1FF0A0074B1B5A4867854943CC883F98AB2447710F386475EDDEA4E1C0208208CF1549F758B961CDBB1E47F70FAFD2801617314A2DA7392398DCFF0010F4FAD4532B5A5C3CF182C8DFEB17FA8AB72449776E06719F99587507D454292B3234538C4C839F461EA281916871A3683688514868C6E0475AD35508815400A3800741593A1DCC31E896A5DF1B63031DCD3A5D52495BCBB4898B7B0C9FFEB536234A691635CBB051EA6A85C6AC918DB0AE49E84FF85322D36E6760F752ECF607737F80AD1B7B1B7B7FF5718DDDD8F24FE34AC065ADB5F5F36E98F949EAFD7F05AD0B7D3ADE03B8A991FF00BCFCFF00FAAADD19A601DE9CAB93FD6A37758C65D828F7353A7029A10F0001814B49455885A28A2800A42334B4868029CF10E548055BB1AC4B9B696C25FB45B93E5F7FF67D8FA8AE8E55DCA4554600E548C83C1150D0D15ED2EE3BB8B23861F797D29CE9B9597009C719ACEBCB37B47173684851D47F77FF00AD576CEE92EE3C70AE07233FAD48C646E6C5D51F3E43743FDC3FE157D9438E808239F7A82E230F180464631505BCA6D5C45213E49FBAC7F87D8FB5003A306CDC213FB863F293FC07D0FB54B770F9B18753B644FBADFD3E9561D16442A40208C1154919ADCF932125483E5B9FE47DE8028E89A725C697692CCEC47940045E07E35BB1451C29B234545F403159FE1EFF0090159FFD73157A59E3887CEE07B77AA7A0893A0A338E7359B36A88A4F96BC7F79BFC2A93DCDC5E362357907B0C2D2B8CD596FE08F2036F23B2FF008D67DC6AEF82B1909FEEF27F3A741A54B200D7326D07F812AFC1636F6FCC71807FBC793458467D8453DC5CACB2A308C73B9F926B796A21C91528200C938156B601F4540F7712772DF4AAB2EB10C7D47EB49C920B334A8AC56F10C2BD109A88F89A2CE0427FEFAA5CE87CACDFA4AC07F1322E3F71FF008F52A78911FF00E5901F8D1CE83959B845549571274F7AAA9AD2B9C6D5CFD6A46BC12104C647D0D2724D072B438E707001FAD665E593DBBFDA6CF2A0725476FA7B569AC88FC0C83E869CBC5202A59DF25DA05200907519FD454CD107570704118AA1A859346FF69B50430E4AA8FD47F854FA6DEADCA10C4094751EA3DA800B5B930308673F21E11CF6F6356E789648995D7208A8648565C875C82314C8A56B726DE63F290446E4FE86803234CBC9FF00B32DA18773623030A2AF43A75D4DCCAE2207B753563C3A00D0ECC8C0CC6338EF5A5556114E0D2EDA2C164F31BD5FFC2AE2A855014003D00C52E6933400BD2938A298EC060123268009678E042EE46077ED59171AAB4BFEAC617D4FF8541AA4C6597049DAA78159CD2863B075ED5949B6EC5A48B135E48E71B89FE5559D4C9CBB91F4A0AB630BD7D6A36B72DCBC87F0A6A255C5F2A23FC45BF1A0C11E3814D5876F435201814EC34C89EDD585279281701B07D735331F96AB491331CA9C1A2C31F1C9246D86391D8D6A595D389557F84F6ACA44940C3E187A8ADAD36CDA44572B81DB3536B325B2EC9751DB942F9E4F6EDEF5751D5D4329041E84557B8B28EE63DBF7645E03E3A566C72CFA6CDE548A4C679C7F51576333701ACBBEB02B27DA6D01561F332AFAFA8FF0ABD14C92A2BC6DB95BB8A973C5302858DE0B93B1861F1CFA1FA558BC856485811918AA97F6277FDA2D4112039655EFEE2A6B5BD5B98CABF1280723D6900BE1FF00F901D9F3FF002CC568F7EB5CE695A8B43A4DAC4BB01118F73F9558DF7B71D239483DD8ED154D88D596EA18BEFC801F40726AA49AAC6172884FBB1C0ACBBCB6BDB746976AB28FBDE5F38ACBFB42C872CC49F73480D99B5891B203E07A20FEB54CDF49BC328258720B1CD540C0D3B2290CBD25CC57284C9FBB931E9906B36DB0D3B739EC2A4E0839CE3DA9B69098EE7D548CE68B6A52BD89E46F2D7DEAB33923249AB92C5BAA94B68A5893B8FE34144027224C2B7EB572162E3045578EC806C8502AEC516C140C82E98C29902A9C73976C9602B5EE21124383594D62037DD04500CB1048DE6056C1CF423BD75F6FC4083D1457276B6EAACA40C63B5747657D14FF00BACED957F84F7FA50448BDDC1A8E7823B88CA4AB91D8F71F4A78E9D334B4C930DD2E34B9F232D131EBD9BFC0D6ADB5C47711EF8CFD477153BAA49195750CA4720D62DCDACDA749F68B76262EFEDEC680366A85FD917267B7E251C9038CFF00F5EA5B3BC4B94C8E18755AB4DF70FD28028F876345D12D1822EE318C9C726B45DB0A491D2A978787FC48ACFF00EB98AB9280580F4AA622B313F9D606AFA5A16F3A01B09EB8E95D132FAD412A078CA30EB520712649606DB20C7BD588EE030EB57EF2D8062AE3359135A3464B4471ED4C0BC8E1B8CD5B89B33150380393EF58B0CEC8E15C10735B50E0A8907F17EB536348ED62D6D04734C6414E2D8A8D9F34148690053E25DCE33C0A8595883DAAB933A3E77F1E86828DD952236FB428CE2B21BE590AB7141BB95976A9E69BE53B282C72DEB42D84DA6CB118154E5774B963CED07823A8FA5598DB0403D6A9CA773B1F7A0CE46D586AE080970DC74127F8D6C2B02A083C7B5712A4A9CAD68D86A6F6F85E5A3EE84FF2A093A7C8A5E08208C83D8D5782E62B88B7C4D9FE62A656CE3B1F4A60655E69EF03FDA2CF381C941DBE952D96A0B70851FE5931D3D7E95A3D0D676A1A6093335BFCB28E481C03FF00D7A009BC3FC68367FF005CC55BFBD93D3354742FF900590F58C55FEC78AA622361834C75CD4AC3239A6F152066DFC1B937E391DAB1A6881ED5D3C806718AC6BCB7D929C67079142031DA15EE33EF4A974D00F2802549E0FA55891319AA72C4588C7AF6A45266C46731AE7AE2970073514520200CF6A919815C77A196881EE2346C3301F8D46F323AFCAAC7E9520B0898EE6504F5248A905ADA6EFE389B18CAB508A48A492A21CED6FC454C97B148FB50FE14E7B3B7DDF3C85C0EDCD4C2DA1957F7712AEDE9814034215032FED59B9049E6AFCEC628994F1C62B3B18E9C7BD066C752107391C53096CE371A03B672D80B4845AB6BB960903AB10DEBEBF5AE8AC7518EE4846F924F4CF07E95CA798BEF5224A5718391FCA988ED49A5CE50FD2B0EC357E025C1C8E81FD3EB5B218142410411DA802A683CE8B67ED18ABC49C91D4FA551D007FC492CFF00EB98ABFD2AD884ED49CD38F4E293B52018C2AADCC3E6A103191D2AE1A888C52198122750C2AB98C2B023D6B5EFA0C1DE0707AD516414D093B333A66685C483EEB73FE35660983329CF151129B9A197FD5BF43FDD3EB54FF796726D7C18D8FCAC0F14E713AE50D6E8E954874DA3A5549AD65C92A322A0B5BD000E722B4A3BA8DC03BAB2D513A752847693337CCA40F7ABE9108539A735C281DBF3AA73DDEF6DABF4A3713B228DF4A1A623D2AB820D2DE82B70DC6460735089063AD5332699362985734CF37D29C24CFA521085684709F29EF4EE7BD3481E94012062A772D5FB1D4A4B7F97AA9EA87A7E1E959CA362E3BD29236F3C500757A09C68767FF5CC55F1F4ACDD08FF00C496CC7FD3315A19C568C91D4D279A01A09A4310D348E71486450793CD46D7033F2AE7DCD1615C5993721046735933C2EB900723B55C6B976621719F51559A5DC7771B81E7354909B32EF21240641F37A7AD5225654313F07F91AD7BA2304C9B549E40CD674C88DC965C8FE20C3356690ACD2B333C3C96CE54F415663BA623201A91AD7CF8B89622C3A65803558C125B37CE001F518ACA4AC6974F62D09E56E067F1AB76C87393CD558194F3B97F3157E37403EFAFFDF42A04CCEBD72B7CD838E05235B99577C43E7EEBEB515FB037C5830C103BD69D9A22207665CF61B856CACD6A74C22A71B332DD2485B6CB1946F7A70C9E0353DEEA42EE1983C658FC8C47E87B539638276C5BCBE5BFFCF390F7F635958E26333B4E0F5A7230CF229EB693900B08C0C900971539D3994216921C1EBB587152DD8695CACCC08E8334DC16E31C56BBE996C8C425C094718F9C28AB715A69B142CAE04CE47DE2C060FB734B9A37DC7CAEC0FFD9">
  memref.global "private" constant @__cmr_4 : memref<64xi6> = dense<[0, 1, 5, 6, 14, 15, 27, 28, 2, 4, 7, 13, 16, 26, 29, -22, 3, 8, 12, 17, 25, 30, -23, -21, 9, 11, 18, 24, 31, -24, -20, -11, 10, 19, 23, -32, -25, -19, -12, -10, 20, 22, -31, -26, -18, -13, -9, -4, 21, -30, -27, -17, -14, -8, -5, -3, -29, -28, -16, -15, -7, -6, -2, -1]>
  memref.global "private" constant @__cmr_5 : memref<64xi16> = dense<[1024, 1138, 1730, 1609, 1024, 1609, 1730, 1138, 1138, 1264, 1922, 1788, 1138, 1788, 1922, 1264, 1730, 1922, 2923, 2718, 1730, 2718, 2923, 1922, 1609, 1788, 2718, 2528, 1609, 2528, 2718, 1788, 1024, 1138, 1730, 1609, 1024, 1609, 1730, 1138, 1609, 1788, 2718, 2528, 1609, 2528, 2718, 1788, 1730, 1922, 2923, 2718, 1730, 2718, 2923, 1922, 1138, 1264, 1922, 1788, 1138, 1788, 1922, 1264]>
  cal.network @jpeg__Top_JPEG_Decoder_Parallel() attributes {cal.top}
  {
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %c2_i32 = arith.constant 2 : i32
    %c4_i32 = arith.constant 4 : i32
    %c300_i32 = arith.constant 300 : i32
    %inputPort, %outputPort = fifo.create<i8> (65536) {cal.name = "jpeg__Top_JPEG_Decoder_Parallel.source.out0->decoder.in0"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_0, %outputPort_1 = fifo.create<i8> (65536) {cal.name = "jpeg__Top_JPEG_Decoder_Parallel.decoder.out1->display.in0"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_2, %outputPort_3 = fifo.create<i16> (65536) {cal.name = "jpeg__Top_JPEG_Decoder_Parallel.decoder.out0->display.in1"} : !fifo.input_port<i16>, !fifo.output_port<i16>
    cal.create_instance @jpeg_io__Display "display" ()
        ports_in (%outputPort_1, %outputPort_3 : !fifo.output_port<i8>, !fifo.output_port<i16>)
    %inputPort_4, %outputPort_5 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.parser.out0->huffman.in0"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_6, %outputPort_7 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.parser.out4->huffman.in1"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_8, %outputPort_9 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.parser.out1->iq_Y.in1"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_10, %outputPort_11 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.parser.out2->iq_Cb.in1"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_12, %outputPort_13 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.parser.out3->iq_Cr.in1"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_14, %outputPort_15 = fifo.create<i16> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.parser.out5->jpeg_decoder_parallel__JpegDecoderParallel.__fanout_i16_5.10.in0"} : !fifo.input_port<i16>, !fifo.output_port<i16>
    %inputPort_16, %outputPort_17 = fifo.create<i16> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.jpeg_decoder_parallel__JpegDecoderParallel.__fanout_i16_5.10.out1->huffman.in2"} : !fifo.input_port<i16>, !fifo.output_port<i16>
    %inputPort_18, %outputPort_19 = fifo.create<i16> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.jpeg_decoder_parallel__JpegDecoderParallel.__fanout_i16_5.10.out2->iq_Y.in0"} : !fifo.input_port<i16>, !fifo.output_port<i16>
    %inputPort_20, %outputPort_21 = fifo.create<i16> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.jpeg_decoder_parallel__JpegDecoderParallel.__fanout_i16_5.10.out3->iq_Cb.in0"} : !fifo.input_port<i16>, !fifo.output_port<i16>
    %inputPort_22, %outputPort_23 = fifo.create<i16> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.jpeg_decoder_parallel__JpegDecoderParallel.__fanout_i16_5.10.out4->iq_Cr.in0"} : !fifo.input_port<i16>, !fifo.output_port<i16>
    %inputPort_24, %outputPort_25 = fifo.create<i24> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.huffman.out0->splitter420.in0"} : !fifo.input_port<i24>, !fifo.output_port<i24>
    %inputPort_26, %outputPort_27 = fifo.create<i24> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.splitter420.out0->iq_Y.in2"} : !fifo.input_port<i24>, !fifo.output_port<i24>
    %inputPort_28, %outputPort_29 = fifo.create<i24> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.splitter420.out1->iq_Cb.in2"} : !fifo.input_port<i24>, !fifo.output_port<i24>
    %inputPort_30, %outputPort_31 = fifo.create<i24> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.splitter420.out2->iq_Cr.in2"} : !fifo.input_port<i24>, !fifo.output_port<i24>
    %inputPort_32, %outputPort_33 = fifo.create<i13> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.iq_Y.out0->idct_Y.in0"} : !fifo.input_port<i13>, !fifo.output_port<i13>
    %inputPort_34, %outputPort_35 = fifo.create<i13> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.iq_Cb.out0->idct_Cb.in0"} : !fifo.input_port<i13>, !fifo.output_port<i13>
    %inputPort_36, %outputPort_37 = fifo.create<i13> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.iq_Cr.out0->idct_Cr.in0"} : !fifo.input_port<i13>, !fifo.output_port<i13>
    %inputPort_38, %outputPort_39 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.idct_Y.out0->merger.in0"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_40, %outputPort_41 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.idct_Cb.out0->merger.in1"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    %inputPort_42, %outputPort_43 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel__JpegDecoderParallel.idct_Cr.out0->merger.in2"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    cal.create_instance @jpeg_decoder_parallel_huffman__Huffman420 "huffman" ()
        ports_in (%outputPort_5, %outputPort_7, %outputPort_17 : !fifo.output_port<i8>, !fifo.output_port<i8>, !fifo.output_port<i16>)
        ports_out (%inputPort_24 : !fifo.input_port<i24>)
    cal.create_instance @jpeg_decoder_parallel_dequant__Dequant__v__mb_4$spec_3615608688897599026 "iq_Y" (%c4_i32 : i32)
        ports_in (%outputPort_19, %outputPort_9, %outputPort_27 : !fifo.output_port<i16>, !fifo.output_port<i8>, !fifo.output_port<i24>)
        ports_out (%inputPort_32 : !fifo.input_port<i13>)
    %inputPort_44, %outputPort_45 = fifo.create<i8> (65536) {cal.name = "jpeg_decoder_parallel_parser__Parser.parse.out1->splitQT.in0"} : !fifo.input_port<i8>, !fifo.output_port<i8>
    cal.create_instance @jpeg_decoder_parallel_parser__SplitQT "splitQT" ()
        ports_in (%outputPort_45 : !fifo.output_port<i8>)
        ports_out (%inputPort_8, %inputPort_10, %inputPort_12 : !fifo.input_port<i8>, !fifo.input_port<i8>, !fifo.input_port<i8>)
    cal.create_instance @jpeg_decoder_parallel_parser__ParseJPEG "parse" ()
        ports_in (%outputPort : !fifo.output_port<i8>)
        ports_out (%inputPort_4, %inputPort_44, %inputPort_6, %inputPort_14 : !fifo.input_port<i8>, !fifo.input_port<i8>, !fifo.input_port<i8>, !fifo.input_port<i16>)
    %inputPort_46, %outputPort_47 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_6005749476377291698.scale.out0->row.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_48, %outputPort_49 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_6005749476377291698.row.out0->transpose.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_50, %outputPort_51 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_6005749476377291698.transpose.out0->column.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_52, %outputPort_53 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_6005749476377291698.column.out0->retranspose.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_54, %outputPort_55 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_6005749476377291698.retranspose.out0->shift.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    cal.create_instance @jpeg_decoder_parallel_idct__Scale__v__index_0$spec_5973899596462999001 "scale" (%c2_i32 : i32)
        ports_in (%outputPort_37 : !fifo.output_port<i13>)
        ports_out (%inputPort_46 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Rightshift__v__index_0$spec_12006719495379002532 "shift" (%c2_i32 : i32)
        ports_in (%outputPort_55 : !fifo.output_port<i32>)
        ports_out (%inputPort_42 : !fifo.input_port<i8>)
    cal.create_instance @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_16004628908213936899 "transpose" (%c2_i32 : i32)
        ports_in (%outputPort_49 : !fifo.output_port<i32>)
        ports_out (%inputPort_50 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_13175051422739902479 "column" (%c2_i32 : i32)
        ports_in (%outputPort_51 : !fifo.output_port<i32>)
        ports_out (%inputPort_52 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_16004628908213936899 "retranspose" (%c2_i32 : i32)
        ports_in (%outputPort_53 : !fifo.output_port<i32>)
        ports_out (%inputPort_54 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_13175051422739902479 "row" (%c2_i32 : i32)
        ports_in (%outputPort_47 : !fifo.output_port<i32>)
        ports_out (%inputPort_48 : !fifo.input_port<i32>)
    %inputPort_56, %outputPort_57 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_1327636489686116372.scale.out0->row.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_58, %outputPort_59 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_1327636489686116372.row.out0->transpose.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_60, %outputPort_61 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_1327636489686116372.transpose.out0->column.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_62, %outputPort_63 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_1327636489686116372.column.out0->retranspose.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_64, %outputPort_65 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_1327636489686116372.retranspose.out0->shift.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    cal.create_instance @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_8975415057449214135 "row" (%c1_i32 : i32)
        ports_in (%outputPort_57 : !fifo.output_port<i32>)
        ports_out (%inputPort_58 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_7626260950822058466 "transpose" (%c1_i32 : i32)
        ports_in (%outputPort_59 : !fifo.output_port<i32>)
        ports_out (%inputPort_60 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_8975415057449214135 "column" (%c1_i32 : i32)
        ports_in (%outputPort_61 : !fifo.output_port<i32>)
        ports_out (%inputPort_62 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_7626260950822058466 "retranspose" (%c1_i32 : i32)
        ports_in (%outputPort_63 : !fifo.output_port<i32>)
        ports_out (%inputPort_64 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Scale__v__index_0$spec_13555646153602813362 "scale" (%c1_i32 : i32)
        ports_in (%outputPort_35 : !fifo.output_port<i13>)
        ports_out (%inputPort_56 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Rightshift__v__index_0$spec_14167312006875771836 "shift" (%c1_i32 : i32)
        ports_in (%outputPort_65 : !fifo.output_port<i32>)
        ports_out (%inputPort_40 : !fifo.input_port<i8>)
    cal.create_instance @jpeg_decoder_parallel_dequant__Dequant__v__mb_1$spec_6088779056661456774 "iq_Cb" (%c1_i32 : i32)
        ports_in (%outputPort_21, %outputPort_11, %outputPort_29 : !fifo.output_port<i16>, !fifo.output_port<i8>, !fifo.output_port<i24>)
        ports_out (%inputPort_34 : !fifo.input_port<i13>)
    cal.create_instance @jpeg_decoder_parallel__Merger420 "merger" ()
        ports_in (%outputPort_39, %outputPort_41, %outputPort_43 : !fifo.output_port<i8>, !fifo.output_port<i8>, !fifo.output_port<i8>)
        ports_out (%inputPort_0 : !fifo.input_port<i8>)
    %inputPort_66, %outputPort_67 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_17559924618070626569.scale.out0->row.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_68, %outputPort_69 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_17559924618070626569.row.out0->transpose.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_70, %outputPort_71 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_17559924618070626569.transpose.out0->column.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_72, %outputPort_73 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_17559924618070626569.column.out0->retranspose.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_74, %outputPort_75 = fifo.create<i32> (65536) {cal.name = "jpeg_decoder_parallel_idct__IDCT2D$spec_17559924618070626569.retranspose.out0->shift.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    cal.create_instance @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_169524333309396437 "column" (%c0_i32 : i32)
        ports_in (%outputPort_71 : !fifo.output_port<i32>)
        ports_out (%inputPort_72 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_10873624104233167978 "transpose" (%c0_i32 : i32)
        ports_in (%outputPort_69 : !fifo.output_port<i32>)
        ports_out (%inputPort_70 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Rightshift__v__index_0$spec_6618446700608443612 "shift" (%c0_i32 : i32)
        ports_in (%outputPort_75 : !fifo.output_port<i32>)
        ports_out (%inputPort_38 : !fifo.input_port<i8>)
    cal.create_instance @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_10873624104233167978 "retranspose" (%c0_i32 : i32)
        ports_in (%outputPort_73 : !fifo.output_port<i32>)
        ports_out (%inputPort_74 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Scale__v__index_0$spec_5840956618029034463 "scale" (%c0_i32 : i32)
        ports_in (%outputPort_33 : !fifo.output_port<i13>)
        ports_out (%inputPort_66 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_169524333309396437 "row" (%c0_i32 : i32)
        ports_in (%outputPort_67 : !fifo.output_port<i32>)
        ports_out (%inputPort_68 : !fifo.input_port<i32>)
    cal.create_instance @jpeg_decoder_parallel_dequant__Dequant__v__mb_1$spec_6088779056661456774 "iq_Cr" (%c1_i32 : i32)
        ports_in (%outputPort_23, %outputPort_13, %outputPort_31 : !fifo.output_port<i16>, !fifo.output_port<i8>, !fifo.output_port<i24>)
        ports_out (%inputPort_36 : !fifo.input_port<i13>)
    cal.create_instance @__fanout_i16_5 "jpeg_decoder_parallel__JpegDecoderParallel.__fanout_i16_5.10" ()
        ports_in (%outputPort_15 : !fifo.output_port<i16>)
        ports_out (%inputPort_2, %inputPort_16, %inputPort_18, %inputPort_20, %inputPort_22 : !fifo.input_port<i16>, !fifo.input_port<i16>, !fifo.input_port<i16>, !fifo.input_port<i16>, !fifo.input_port<i16>)
    cal.create_instance @jpeg_decoder_parallel__Splitter420 "splitter420" ()
        ports_in (%outputPort_25 : !fifo.output_port<i24>)
        ports_out (%inputPort_26, %inputPort_28, %inputPort_30 : !fifo.input_port<i24>, !fifo.input_port<i24>, !fifo.input_port<i24>)
    cal.create_instance @jpeg_io__Source__v__frames_300$spec_9448658579095253651 "source" (%c300_i32 : i32)
        ports_out (%inputPort : !fifo.input_port<i8>)
  }
  
  cal.actor @jpeg_io__Display()
    in_names ["In", "SOI"]
    ports_in (
      %arg0: !fifo.output_port<i8>, 
      %arg1: !fifo.output_port<i16>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c1000000_i32 = arith.constant 1000000 : i32
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=1
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg2 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
        memref.store %2, %alloca[%arg2] : memref<64xi8>
      }
      scf.for %arg2 = %c0 to %c64 step %c1 {
        %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %3 = arith.addi %2, %c1_i32 : i32
        cal.set(%0 : !cal.state_ref<i32>, %3 : i32)
        %4 = cal.get(%1 : !cal.state_ref<i64>) : i64
        %5 = memref.load %alloca[%arg2] : memref<64xi8>
        %6 = arith.extui %5 : i8 to i64
        %7 = arith.addi %4, %6 : i64
        cal.set(%1 : !cal.state_ref<i64>, %7 : i64)
        %8 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %9 = arith.remsi %8, %c1000000_i32 : i32
        %10 = arith.cmpi eq, %9, %c0_i32 : i32
        scf.if %10 {
          %11 = cal.get(%0 : !cal.state_ref<i32>) : i32
          %12 = cal.get(%1 : !cal.state_ref<i64>) : i64
          fifo.print("Received %i bytes, sum is %llu\0A\00", %11, %12) : (i32, i64)
          cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
        }
      }
    }
    
    cal.action "$untagged1" priority=1
    {
      %2 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %3 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_huffman__Huffman420()
    in_names ["Bit", "HT", "SOI"]
    out_names ["Block"]
    ports_in (
      %arg0: !fifo.output_port<i8>, 
      %arg1: !fifo.output_port<i8>, 
      %arg2: !fifo.output_port<i16>
    )
    ports_out (
      %arg3: !fifo.input_port<i24>
    )
  {
    %c64_i64 = arith.constant 64 : i64
    %c0_i24 = arith.constant 0 : i24
    %c64 = arith.constant 64 : index
    %c-1_i32 = arith.constant -1 : i32
    %c16 = arith.constant 16 : index
    %c3 = arith.constant 3 : index
    %c6_i64 = arith.constant 6 : i64
    %c2_i64 = arith.constant 2 : i64
    %c0_i64 = arith.constant 0 : i64
    %c0_i8 = arith.constant 0 : i8
    %c0_i16 = arith.constant 0 : i16
    %c2 = arith.constant 2 : index
    %true = arith.constant true
    %c63_i32 = arith.constant 63 : i32
    %c16_i32 = arith.constant 16 : i32
    %c65535_i32 = arith.constant 65535 : i32
    %c4_i32 = arith.constant 4 : i32
    %c1000000000_i32 = arith.constant 1000000000 : i32
    %c32768_i32 = arith.constant 32768 : i32
    %c15_i32 = arith.constant 15 : i32
    %c3_i32 = arith.constant 3 : i32
    %c0 = arith.constant 0 : index
    %c17 = arith.constant 17 : index
    %c1 = arith.constant 1 : index
    %c1_i32 = arith.constant 1 : i32
    %c7_i32 = arith.constant 7 : i32
    %false = arith.constant false
    %c256_i32 = arith.constant 256 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i16> : !cal.state_ref<i16>
    cal.set(%1 : !cal.state_ref<i16>, %c0_i16 : i16)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c0_i32 : i32)
    %4 = cal.create_state_var<i8> : !cal.state_ref<i8>
    cal.set(%4 : !cal.state_ref<i8>, %c0_i8 : i8)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c0_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c0_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c0_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c0_i32 : i32)
    %10 = cal.create_state_var<i8> : !cal.state_ref<i8>
    cal.set(%10 : !cal.state_ref<i8>, %c0_i8 : i8)
    %11 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%11 : !cal.state_ref<i64>, %c0_i64 : i64)
    %12 = cal.create_state_var<memref<3xi8>> : !cal.state_ref<memref<3xi8>>
    %13 = cal.get(%12 : !cal.state_ref<memref<3xi8>>) : memref<3xi8>
    %14 = memref.get_global @__cmr_0 : memref<3xi8>
    memref.copy %14, %13 : memref<3xi8> to memref<3xi8>
    %15 = cal.create_state_var<memref<3xi8>> : !cal.state_ref<memref<3xi8>>
    %16 = cal.get(%15 : !cal.state_ref<memref<3xi8>>) : memref<3xi8>
    %17 = memref.get_global @__cmr_1 : memref<3xi8>
    memref.copy %17, %16 : memref<3xi8> to memref<3xi8>
    %18 = cal.create_state_var<memref<4x256xi32>> : !cal.state_ref<memref<4x256xi32>>
    %19 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%19 : !cal.state_ref<i32>, %c256_i32 : i32)
    %20 = cal.create_state_var<memref<4x256xi32>> : !cal.state_ref<memref<4x256xi32>>
    %21 = cal.create_state_var<memref<4x256xi32>> : !cal.state_ref<memref<4x256xi32>>
    %22 = cal.create_state_var<memref<16xi8>> : !cal.state_ref<memref<16xi8>>
    %23 = cal.create_state_var<memref<256xi8>> : !cal.state_ref<memref<256xi8>>
    %24 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%24 : !cal.state_ref<i32>, %c0_i32 : i32)
    %25 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%25 : !cal.state_ref<i32>, %c0_i32 : i32)
    %26 = cal.create_state_var<memref<3xi32>> : !cal.state_ref<memref<3xi32>>
    %27 = cal.get(%26 : !cal.state_ref<memref<3xi32>>) : memref<3xi32>
    %28 = memref.get_global @__cmr_2 : memref<3xi32>
    memref.copy %28, %27 : memref<3xi32> to memref<3xi32>
    %29 = cal.create_state_var<memref<3xi32>> : !cal.state_ref<memref<3xi32>>
    %30 = cal.create_state_var<memref<64xi24>> : !cal.state_ref<memref<64xi24>>
    cal.fsm {
      cal.state @waitSOI {
        cal.transition action("getSOI") -> @wait_HT
      } {initial}
      cal.state @wait_AC {
        cal.transition action("EOB") -> @wait_DC_len
        cal.transition action("getbit.read") -> @wait_AC
        cal.transition action("getbit.noread") -> @wait_AC
        cal.transition action("AC.done") -> @wait_AC_len
      }
      cal.state @wait_AC_len {
        cal.transition action("getbit.read") -> @wait_AC_len
        cal.transition action("getbit.noread") -> @wait_AC_len
        cal.transition action("AC.done_len") -> @wait_AC
      }
      cal.state @wait_DC {
        cal.transition action("getbit.read") -> @wait_DC
        cal.transition action("getbit.noread") -> @wait_DC
        cal.transition action("DC.done") -> @wait_AC_len
      }
      cal.state @wait_DC_len {
        cal.transition action("EOI") -> @waitSOI
        cal.transition action("getbit.read") -> @wait_DC_len
        cal.transition action("getbit.noread") -> @wait_DC_len
        cal.transition action("DC.done_len") -> @wait_DC
      }
      cal.state @wait_HT {
        cal.transition action("receive_HT_len") -> @wait_code
        cal.transition action("done_HT") -> @wait_DC_len
      }
      cal.state @wait_code {
        cal.transition action("receive_code") -> @wait_code
        cal.transition action("build_HT") -> @wait_HT
      }
    }
    cal.action "getbit.read" priority=11
    {
      cal.predicate {
        %52 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %53 = arith.cmpi ne, %52, %c0_i32 : i32
        %54 = cal.get(%9 : !cal.state_ref<i32>) : i32
        %55 = arith.cmpi eq, %54, %c0_i32 : i32
        %56 = arith.select %53, %55, %false : i1
        cal.predicate_result %56 : i1
      }
      %31 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      cal.set(%10 : !cal.state_ref<i8>, %31 : i8)
      %32 = cal.get(%1 : !cal.state_ref<i16>) : i16
      %33 = arith.extui %32 : i16 to i64
      %34 = arith.muli %33, %c2_i64 : i64
      %35 = cal.get(%10 : !cal.state_ref<i8>) : i8
      %36 = cal.get(%9 : !cal.state_ref<i32>) : i32
      %37 = arith.subi %c7_i32, %36 : i32
      %38 = arith.extui %35 : i8 to i32
      %39 = arith.shrsi %38, %37 : i32
      %40 = arith.andi %39, %c1_i32 : i32
      %41 = arith.trunci %40 : i32 to i1
      %42 = arith.extui %41 : i1 to i64
      %43 = arith.addi %34, %42 : i64
      %44 = arith.trunci %43 : i64 to i16
      cal.set(%1 : !cal.state_ref<i16>, %44 : i16)
      %45 = cal.get(%3 : !cal.state_ref<i32>) : i32
      %46 = arith.subi %45, %c1_i32 : i32
      cal.set(%3 : !cal.state_ref<i32>, %46 : i32)
      %47 = cal.get(%2 : !cal.state_ref<i32>) : i32
      %48 = arith.addi %47, %c1_i32 : i32
      cal.set(%2 : !cal.state_ref<i32>, %48 : i32)
      %49 = cal.get(%9 : !cal.state_ref<i32>) : i32
      %50 = arith.addi %49, %c1_i32 : i32
      %51 = arith.andi %50, %c7_i32 : i32
      cal.set(%9 : !cal.state_ref<i32>, %51 : i32)
    }
    
    cal.action "getbit.noread" priority=12
    {
      cal.predicate {
        %51 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %52 = arith.cmpi ne, %51, %c0_i32 : i32
        %53 = cal.get(%9 : !cal.state_ref<i32>) : i32
        %54 = arith.cmpi ne, %53, %c0_i32 : i32
        %55 = arith.select %52, %54, %false : i1
        cal.predicate_result %55 : i1
      }
      %31 = cal.get(%1 : !cal.state_ref<i16>) : i16
      %32 = arith.extui %31 : i16 to i64
      %33 = arith.muli %32, %c2_i64 : i64
      %34 = cal.get(%10 : !cal.state_ref<i8>) : i8
      %35 = cal.get(%9 : !cal.state_ref<i32>) : i32
      %36 = arith.subi %c7_i32, %35 : i32
      %37 = arith.extui %34 : i8 to i32
      %38 = arith.shrsi %37, %36 : i32
      %39 = arith.andi %38, %c1_i32 : i32
      %40 = arith.trunci %39 : i32 to i1
      %41 = arith.extui %40 : i1 to i64
      %42 = arith.addi %33, %41 : i64
      %43 = arith.trunci %42 : i64 to i16
      cal.set(%1 : !cal.state_ref<i16>, %43 : i16)
      %44 = cal.get(%3 : !cal.state_ref<i32>) : i32
      %45 = arith.subi %44, %c1_i32 : i32
      cal.set(%3 : !cal.state_ref<i32>, %45 : i32)
      %46 = cal.get(%2 : !cal.state_ref<i32>) : i32
      %47 = arith.addi %46, %c1_i32 : i32
      cal.set(%2 : !cal.state_ref<i32>, %47 : i32)
      %48 = cal.get(%9 : !cal.state_ref<i32>) : i32
      %49 = arith.addi %48, %c1_i32 : i32
      %50 = arith.andi %49, %c7_i32 : i32
      cal.set(%9 : !cal.state_ref<i32>, %50 : i32)
    }
    
    cal.action "getSOI" priority=12
    {
      %31 = fifo.pop(%arg2 : !fifo.output_port<i16>) : i16
      %32 = fifo.pop(%arg2 : !fifo.output_port<i16>) : i16
      %33 = arith.extui %31 : i16 to i64
      %34 = arith.muli %33, %c6_i64 : i64
      %35 = arith.extui %32 : i16 to i64
      %36 = arith.muli %34, %35 : i64
      %37 = arith.trunci %36 : i64 to i32
      cal.set(%8 : !cal.state_ref<i32>, %37 : i32)
      scf.for %arg4 = %c0 to %c3 step %c1 {
        %38 = cal.get(%29 : !cal.state_ref<memref<3xi32>>) : memref<3xi32>
        memref.store %c0_i32, %38[%arg4] : memref<3xi32>
      }
    }
    
    cal.action "receive_HT_len" priority=11
    {
      %alloca = memref.alloca() : memref<17xi8>
      scf.for %arg4 = %c0 to %c17 step %c1 {
        %38 = fifo.pop(%arg1 : !fifo.output_port<i8>) : i8
        memref.store %38, %alloca[%arg4] : memref<17xi8>
      }
      cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
      %31 = memref.load %alloca[%c0] : memref<17xi8>
      %32 = arith.extui %31 : i8 to i32
      %33 = arith.shrsi %32, %c3_i32 : i32
      %34 = arith.ori %32, %33 : i32
      %35 = arith.andi %34, %c3_i32 : i32
      %36 = arith.trunci %35 : i32 to i8
      cal.set(%4 : !cal.state_ref<i8>, %36 : i8)
      %37 = scf.for %arg4 = %c0 to %c16 step %c1 iter_args(%arg5 = %c0_i32) -> (i32) {
        %38 = cal.get(%22 : !cal.state_ref<memref<16xi8>>) : memref<16xi8>
        %39 = arith.index_cast %arg4 : index to i32
        %40 = arith.addi %39, %c1_i32 : i32
        %41 = arith.index_cast %40 : i32 to index
        %42 = memref.load %alloca[%41] : memref<17xi8>
        memref.store %42, %38[%arg4] : memref<16xi8>
        %43 = cal.get(%22 : !cal.state_ref<memref<16xi8>>) : memref<16xi8>
        %44 = memref.load %43[%arg4] : memref<16xi8>
        %45 = arith.extui %44 : i8 to i32
        %46 = arith.addi %arg5, %45 : i32
        scf.yield %46 : i32
      }
      cal.set(%3 : !cal.state_ref<i32>, %37 : i32)
    }
    
    cal.action "receive_code" priority=12
    {
      cal.predicate {
        %39 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %40 = arith.cmpi ugt, %39, %c0_i32 : i32
        cal.predicate_result %40 : i1
      }
      %31 = fifo.pop(%arg1 : !fifo.output_port<i8>) : i8
      %32 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %33 = arith.index_cast %32 : i32 to index
      %34 = cal.get(%23 : !cal.state_ref<memref<256xi8>>) : memref<256xi8>
      memref.store %31, %34[%33] : memref<256xi8>
      %35 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %36 = arith.addi %35, %c1_i32 : i32
      cal.set(%5 : !cal.state_ref<i32>, %36 : i32)
      %37 = cal.get(%3 : !cal.state_ref<i32>) : i32
      %38 = arith.subi %37, %c1_i32 : i32
      cal.set(%3 : !cal.state_ref<i32>, %38 : i32)
    }
    
    cal.action "build_HT" priority=12
    {
      cal.predicate {
        %39 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %40 = arith.cmpi eq, %39, %c0_i32 : i32
        cal.predicate_result %40 : i1
      }
      %31:4 = scf.for %arg4 = %c0 to %c16 step %c1 iter_args(%arg5 = %c0_i32, %arg6 = %c0_i32, %arg7 = %c0_i32, %arg8 = %c32768_i32) -> (i32, i32, i32, i32) {
        %39 = arith.index_cast %arg4 : index to i32
        %40 = arith.addi %39, %c1_i32 : i32
        %41 = cal.get(%22 : !cal.state_ref<memref<16xi8>>) : memref<16xi8>
        %42 = memref.load %41[%arg4] : memref<16xi8>
        %43 = arith.extui %42 : i8 to i32
        %44 = arith.subi %43, %c1_i32 : i32
        %45 = arith.index_cast %44 : i32 to index
        %46 = arith.addi %45, %c1 : index
        %47:3 = scf.for %arg9 = %c0 to %46 step %c1 iter_args(%arg10 = %arg5, %arg11 = %arg6, %arg12 = %arg7) -> (i32, i32, i32) {
          %49 = cal.get(%4 : !cal.state_ref<i8>) : i8
          %50 = arith.extui %49 : i8 to i32
          %51 = arith.index_cast %50 : i32 to index
          %52 = cal.get(%23 : !cal.state_ref<memref<256xi8>>) : memref<256xi8>
          %53 = arith.index_cast %arg12 : i32 to index
          %54 = memref.load %52[%53] : memref<256xi8>
          %55 = arith.extui %54 : i8 to i32
          %56 = arith.index_cast %55 : i32 to index
          %57 = cal.get(%18 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
          memref.store %40, %57[%51, %56] : memref<4x256xi32>
          %58 = cal.get(%4 : !cal.state_ref<i8>) : i8
          %59 = arith.extui %58 : i8 to i32
          %60 = arith.index_cast %59 : i32 to index
          %61 = arith.index_cast %arg10 : i32 to index
          %62 = cal.get(%20 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
          memref.store %arg11, %62[%60, %61] : memref<4x256xi32>
          %63 = cal.get(%4 : !cal.state_ref<i8>) : i8
          %64 = arith.extui %63 : i8 to i32
          %65 = arith.index_cast %64 : i32 to index
          %66 = cal.get(%21 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
          %67 = cal.get(%23 : !cal.state_ref<memref<256xi8>>) : memref<256xi8>
          %68 = memref.load %67[%53] : memref<256xi8>
          %69 = arith.extui %68 : i8 to i32
          memref.store %69, %66[%65, %61] : memref<4x256xi32>
          %70 = arith.addi %arg10, %c1_i32 : i32
          %71 = arith.addi %arg11, %arg8 : i32
          %72 = arith.addi %arg12, %c1_i32 : i32
          scf.yield %70, %71, %72 : i32, i32, i32
        }
        %48 = arith.shrsi %arg8, %c1_i32 : i32
        scf.yield %47#0, %47#1, %47#2, %48 : i32, i32, i32, i32
      }
      %32 = cal.get(%4 : !cal.state_ref<i8>) : i8
      %33 = arith.extui %32 : i8 to i32
      %34 = arith.index_cast %33 : i32 to index
      %35 = arith.index_cast %31#0 : i32 to index
      %36 = cal.get(%20 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      memref.store %c1000000000_i32, %36[%34, %35] : memref<4x256xi32>
      %37 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %38 = arith.addi %37, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %38 : i32)
    }
    
    cal.action "done_HT" priority=12
    {
      cal.predicate {
        %35 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %36 = arith.cmpi eq, %35, %c4_i32 : i32
        cal.predicate_result %36 : i1
      }
      cal.set(%6 : !cal.state_ref<i32>, %c65535_i32 : i32)
      cal.set(%25 : !cal.state_ref<i32>, %c0_i32 : i32)
      %31 = cal.get(%12 : !cal.state_ref<memref<3xi8>>) : memref<3xi8>
      %32 = cal.get(%25 : !cal.state_ref<i32>) : i32
      %33 = arith.index_cast %32 : i32 to index
      %34 = memref.load %31[%33] : memref<3xi8>
      cal.set(%4 : !cal.state_ref<i8>, %34 : i8)
      cal.set(%1 : !cal.state_ref<i16>, %c0_i16 : i16)
      cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%3 : !cal.state_ref<i32>, %c16_i32 : i32)
    }
    
    cal.action "DC.done_len" priority=10
    {
      cal.predicate {
        %48 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %49 = arith.cmpi eq, %48, %c0_i32 : i32
        cal.predicate_result %49 : i1
      }
      %31 = cal.get(%4 : !cal.state_ref<i8>) : i8
      %32 = arith.extui %31 : i8 to i32
      %33 = cal.get(%1 : !cal.state_ref<i16>) : i16
      %34 = scf.while (%arg4 = %c0_i32) : (i32) -> i32 {
        %48 = cal.get(%20 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
        %49 = arith.index_cast %32 : i32 to index
        %50 = arith.index_cast %arg4 : i32 to index
        %51 = memref.load %48[%49, %50] : memref<4x256xi32>
        %52 = arith.extui %33 : i16 to i32
        %53 = arith.cmpi uge, %52, %51 : i32
        scf.condition(%53) %arg4 : i32
      } do {
      ^bb0(%arg4: i32):
        %48 = arith.addi %arg4, %c1_i32 : i32
        scf.yield %48 : i32
      }
      %35 = cal.get(%21 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %36 = arith.index_cast %32 : i32 to index
      %37 = arith.subi %34, %c1_i32 : i32
      %38 = arith.index_cast %37 : i32 to index
      %39 = memref.load %35[%36, %38] : memref<4x256xi32>
      cal.set(%6 : !cal.state_ref<i32>, %39 : i32)
      %40 = cal.get(%18 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %41 = cal.get(%4 : !cal.state_ref<i8>) : i8
      %42 = arith.extui %41 : i8 to i32
      %43 = arith.index_cast %42 : i32 to index
      %44 = cal.get(%6 : !cal.state_ref<i32>) : i32
      %45 = arith.index_cast %44 : i32 to index
      %46 = memref.load %40[%43, %45] : memref<4x256xi32>
      cal.set(%3 : !cal.state_ref<i32>, %46 : i32)
      %47 = cal.get(%3 : !cal.state_ref<i32>) : i32
      cal.set(%2 : !cal.state_ref<i32>, %47 : i32)
    }
    
    cal.action "DC.done" priority=12
    {
      cal.predicate {
        %55 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %56 = arith.cmpi eq, %55, %c0_i32 : i32
        cal.predicate_result %56 : i1
      }
      %31 = cal.get(%6 : !cal.state_ref<i32>) : i32
      %32 = arith.andi %31, %c15_i32 : i32
      cal.set(%3 : !cal.state_ref<i32>, %32 : i32)
      %33 = cal.get(%3 : !cal.state_ref<i32>) : i32
      cal.set(%2 : !cal.state_ref<i32>, %33 : i32)
      %34 = cal.get(%1 : !cal.state_ref<i16>) : i16
      %35 = cal.get(%3 : !cal.state_ref<i32>) : i32
      %36 = arith.subi %c16_i32, %35 : i32
      %37 = arith.extui %34 : i16 to i32
      %38 = arith.shrsi %37, %36 : i32
      %39 = cal.get(%2 : !cal.state_ref<i32>) : i32
      %40 = arith.subi %39, %c1_i32 : i32
      %41 = arith.shli %c1_i32, %40 : i32
      %42 = arith.cmpi slt, %38, %41 : i32
      %43 = scf.if %42 -> (i32) {
        %55 = cal.get(%2 : !cal.state_ref<i32>) : i32
        %56 = arith.shli %c-1_i32, %55 : i32
        %57 = arith.addi %38, %56 : i32
        %58 = arith.addi %57, %c1_i32 : i32
        scf.yield %58 : i32
      } else {
        scf.yield %38 : i32
      }
      %44 = cal.get(%29 : !cal.state_ref<memref<3xi32>>) : memref<3xi32>
      %45 = cal.get(%25 : !cal.state_ref<i32>) : i32
      %46 = arith.index_cast %45 : i32 to index
      %47 = memref.load %44[%46] : memref<3xi32>
      %48 = arith.addi %43, %47 : i32
      memref.store %48, %44[%46] : memref<3xi32>
      cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
      %49 = cal.get(%15 : !cal.state_ref<memref<3xi8>>) : memref<3xi8>
      %50 = cal.get(%25 : !cal.state_ref<i32>) : i32
      %51 = arith.index_cast %50 : i32 to index
      %52 = memref.load %49[%51] : memref<3xi8>
      cal.set(%4 : !cal.state_ref<i8>, %52 : i8)
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %55 = cal.get(%30 : !cal.state_ref<memref<64xi24>>) : memref<64xi24>
        memref.store %c0_i24, %55[%arg4] : memref<64xi24>
      }
      cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
      %53 = cal.get(%30 : !cal.state_ref<memref<64xi24>>) : memref<64xi24>
      %54 = arith.trunci %48 : i32 to i24
      memref.store %54, %53[%c0] : memref<64xi24>
    }
    
    cal.action "AC.done_len" priority=12
    {
      cal.predicate {
        %53 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %54 = arith.cmpi eq, %53, %c0_i32 : i32
        cal.predicate_result %54 : i1
      }
      %31 = cal.get(%4 : !cal.state_ref<i8>) : i8
      %32 = arith.extui %31 : i8 to i32
      %33 = cal.get(%1 : !cal.state_ref<i16>) : i16
      %34 = scf.while (%arg4 = %c0_i32) : (i32) -> i32 {
        %53 = cal.get(%20 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
        %54 = arith.index_cast %32 : i32 to index
        %55 = arith.index_cast %arg4 : i32 to index
        %56 = memref.load %53[%54, %55] : memref<4x256xi32>
        %57 = arith.extui %33 : i16 to i32
        %58 = arith.cmpi uge, %57, %56 : i32
        scf.condition(%58) %arg4 : i32
      } do {
      ^bb0(%arg4: i32):
        %53 = arith.addi %arg4, %c1_i32 : i32
        scf.yield %53 : i32
      }
      %35 = cal.get(%21 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %36 = arith.index_cast %32 : i32 to index
      %37 = arith.subi %34, %c1_i32 : i32
      %38 = arith.index_cast %37 : i32 to index
      %39 = memref.load %35[%36, %38] : memref<4x256xi32>
      cal.set(%6 : !cal.state_ref<i32>, %39 : i32)
      %40 = cal.get(%18 : !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %41 = cal.get(%4 : !cal.state_ref<i8>) : i8
      %42 = arith.extui %41 : i8 to i32
      %43 = arith.index_cast %42 : i32 to index
      %44 = cal.get(%6 : !cal.state_ref<i32>) : i32
      %45 = arith.index_cast %44 : i32 to index
      %46 = memref.load %40[%43, %45] : memref<4x256xi32>
      cal.set(%3 : !cal.state_ref<i32>, %46 : i32)
      %47 = cal.get(%3 : !cal.state_ref<i32>) : i32
      cal.set(%2 : !cal.state_ref<i32>, %47 : i32)
      %48 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %49 = cal.get(%6 : !cal.state_ref<i32>) : i32
      %50 = arith.shrsi %49, %c4_i32 : i32
      %51 = arith.addi %48, %50 : i32
      %52 = arith.addi %51, %c1_i32 : i32
      cal.set(%5 : !cal.state_ref<i32>, %52 : i32)
    }
    
    cal.action "AC.done" priority=9
    {
      cal.predicate {
        %48 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %49 = arith.cmpi eq, %48, %c0_i32 : i32
        cal.predicate_result %49 : i1
      }
      %31 = cal.get(%6 : !cal.state_ref<i32>) : i32
      %32 = arith.andi %31, %c15_i32 : i32
      cal.set(%3 : !cal.state_ref<i32>, %32 : i32)
      %33 = cal.get(%3 : !cal.state_ref<i32>) : i32
      cal.set(%2 : !cal.state_ref<i32>, %33 : i32)
      %34 = cal.get(%1 : !cal.state_ref<i16>) : i16
      %35 = cal.get(%3 : !cal.state_ref<i32>) : i32
      %36 = arith.subi %c16_i32, %35 : i32
      %37 = arith.extui %34 : i16 to i32
      %38 = arith.shrsi %37, %36 : i32
      %39 = cal.get(%2 : !cal.state_ref<i32>) : i32
      %40 = arith.subi %39, %c1_i32 : i32
      %41 = arith.shli %c1_i32, %40 : i32
      %42 = arith.cmpi slt, %38, %41 : i32
      %43 = scf.if %42 -> (i32) {
        %48 = cal.get(%2 : !cal.state_ref<i32>) : i32
        %49 = arith.shli %c-1_i32, %48 : i32
        %50 = arith.addi %38, %49 : i32
        %51 = arith.addi %50, %c1_i32 : i32
        scf.yield %51 : i32
      } else {
        scf.yield %38 : i32
      }
      %44 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %45 = arith.index_cast %44 : i32 to index
      %46 = cal.get(%30 : !cal.state_ref<memref<64xi24>>) : memref<64xi24>
      %47 = arith.trunci %43 : i32 to i24
      memref.store %47, %46[%45] : memref<64xi24>
    }
    
    cal.action "EOB" priority=10
    {
      cal.predicate {
        %52 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %53 = arith.cmpi eq, %52, %c0_i32 : i32
        %54 = cal.get(%6 : !cal.state_ref<i32>) : i32
        %55 = arith.cmpi eq, %54, %c0_i32 : i32
        %56 = cal.get(%5 : !cal.state_ref<i32>) : i32
        %57 = arith.cmpi eq, %56, %c63_i32 : i32
        %58 = arith.select %55, %true, %57 : i1
        %59 = arith.select %53, %58, %false : i1
        cal.predicate_result %59 : i1
      }
      %31 = cal.get(%24 : !cal.state_ref<i32>) : i32
      %32 = arith.addi %31, %c1_i32 : i32
      cal.set(%24 : !cal.state_ref<i32>, %32 : i32)
      %33 = cal.get(%24 : !cal.state_ref<i32>) : i32
      %34 = cal.get(%26 : !cal.state_ref<memref<3xi32>>) : memref<3xi32>
      %35 = cal.get(%25 : !cal.state_ref<i32>) : i32
      %36 = arith.index_cast %35 : i32 to index
      %37 = memref.load %34[%36] : memref<3xi32>
      %38 = arith.cmpi eq, %33, %37 : i32
      scf.if %38 {
        cal.set(%24 : !cal.state_ref<i32>, %c0_i32 : i32)
        %52 = cal.get(%25 : !cal.state_ref<i32>) : i32
        %53 = arith.addi %52, %c1_i32 : i32
        cal.set(%25 : !cal.state_ref<i32>, %53 : i32)
        %54 = cal.get(%25 : !cal.state_ref<i32>) : i32
        %55 = arith.cmpi eq, %54, %c3_i32 : i32
        scf.if %55 {
          cal.set(%25 : !cal.state_ref<i32>, %c0_i32 : i32)
        }
      }
      %39 = cal.get(%12 : !cal.state_ref<memref<3xi8>>) : memref<3xi8>
      %40 = cal.get(%25 : !cal.state_ref<i32>) : i32
      %41 = arith.index_cast %40 : i32 to index
      %42 = memref.load %39[%41] : memref<3xi8>
      cal.set(%4 : !cal.state_ref<i8>, %42 : i8)
      cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%3 : !cal.state_ref<i32>, %c0_i32 : i32)
      %43 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %44 = arith.cmpi eq, %43, %c63_i32 : i32
      %45 = cal.get(%6 : !cal.state_ref<i32>) : i32
      %46 = arith.cmpi ne, %45, %c0_i32 : i32
      %47 = arith.select %44, %46, %false : i1
      scf.if %47 {
        %52 = cal.get(%6 : !cal.state_ref<i32>) : i32
        %53 = arith.andi %52, %c15_i32 : i32
        cal.set(%3 : !cal.state_ref<i32>, %53 : i32)
        %54 = cal.get(%3 : !cal.state_ref<i32>) : i32
        cal.set(%2 : !cal.state_ref<i32>, %54 : i32)
        %55 = cal.get(%1 : !cal.state_ref<i16>) : i16
        %56 = cal.get(%3 : !cal.state_ref<i32>) : i32
        %57 = arith.subi %c16_i32, %56 : i32
        %58 = arith.extui %55 : i16 to i32
        %59 = arith.shrsi %58, %57 : i32
        %60 = cal.get(%2 : !cal.state_ref<i32>) : i32
        %61 = arith.subi %60, %c1_i32 : i32
        %62 = arith.shli %c1_i32, %61 : i32
        %63 = arith.cmpi slt, %59, %62 : i32
        %64 = scf.if %63 -> (i32) {
          %69 = cal.get(%2 : !cal.state_ref<i32>) : i32
          %70 = arith.shli %c-1_i32, %69 : i32
          %71 = arith.addi %59, %70 : i32
          %72 = arith.addi %71, %c1_i32 : i32
          scf.yield %72 : i32
        } else {
          scf.yield %59 : i32
        }
        %65 = cal.get(%5 : !cal.state_ref<i32>) : i32
        %66 = arith.index_cast %65 : i32 to index
        %67 = cal.get(%30 : !cal.state_ref<memref<64xi24>>) : memref<64xi24>
        %68 = arith.trunci %64 : i32 to i24
        memref.store %68, %67[%66] : memref<64xi24>
        cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
      }
      %48 = cal.get(%7 : !cal.state_ref<i32>) : i32
      %49 = arith.addi %48, %c1_i32 : i32
      cal.set(%7 : !cal.state_ref<i32>, %49 : i32)
      %50 = cal.get(%11 : !cal.state_ref<i64>) : i64
      %51 = arith.addi %50, %c64_i64 : i64
      cal.set(%11 : !cal.state_ref<i64>, %51 : i64)
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %52 = cal.get(%30 : !cal.state_ref<memref<64xi24>>) : memref<64xi24>
        %53 = memref.load %52[%arg4] : memref<64xi24>
        fifo.push(%arg3 : !fifo.input_port<i24>, %53 : i24)
      }
    }
    
    cal.action "EOI" priority=12
    {
      cal.predicate {
        %32 = cal.get(%7 : !cal.state_ref<i32>) : i32
        %33 = cal.get(%8 : !cal.state_ref<i32>) : i32
        %34 = arith.cmpi eq, %32, %33 : i32
        cal.predicate_result %34 : i1
      }
      cal.set(%7 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%9 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%8 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%1 : !cal.state_ref<i16>, %c0_i16 : i16)
      cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%3 : !cal.state_ref<i32>, %c0_i32 : i32)
      %31 = cal.get(%29 : !cal.state_ref<memref<3xi32>>) : memref<3xi32>
      memref.store %c0_i32, %31[%c0] : memref<3xi32>
      memref.store %c0_i32, %31[%c1] : memref<3xi32>
      memref.store %c0_i32, %31[%c2] : memref<3xi32>
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel__Splitter420()
    in_names ["YCbCr"]
    out_names ["Y", "Cb", "Cr"]
    ports_in (
      %arg0: !fifo.output_port<i24>
    )
    ports_out (
      %arg1: !fifo.input_port<i24>, 
      %arg2: !fifo.input_port<i24>, 
      %arg3: !fifo.input_port<i24>
    )
  {
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%0 : !cal.state_ref<i64>, %c0_i64 : i64)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.fsm {
      cal.state @Y0 {
        cal.transition action("Y") -> @Y1
      } {initial}
      cal.state @Cb {
        cal.transition action("Cb") -> @Cr
      }
      cal.state @Cr {
        cal.transition action("Cr") -> @Y0
      }
      cal.state @Y1 {
        cal.transition action("Y") -> @Y2
      }
      cal.state @Y2 {
        cal.transition action("Y") -> @Y3
      }
      cal.state @Y3 {
        cal.transition action("Y") -> @Cb
      }
    }
    cal.action "Y" priority=2
    {
      %alloca = memref.alloca() : memref<64xi24>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %4 = fifo.pop(%arg0 : !fifo.output_port<i24>) : i24
        memref.store %4, %alloca[%arg4] : memref<64xi24>
      }
      %2 = cal.get(%1 : !cal.state_ref<i64>) : i64
      %3 = arith.addi %2, %c64_i64 : i64
      cal.set(%1 : !cal.state_ref<i64>, %3 : i64)
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %4 = memref.load %alloca[%arg4] : memref<64xi24>
        fifo.push(%arg1 : !fifo.input_port<i24>, %4 : i24)
      }
    }
    
    cal.action "Cb" priority=2
    {
      %alloca = memref.alloca() : memref<64xi24>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %4 = fifo.pop(%arg0 : !fifo.output_port<i24>) : i24
        memref.store %4, %alloca[%arg4] : memref<64xi24>
      }
      %2 = cal.get(%1 : !cal.state_ref<i64>) : i64
      %3 = arith.addi %2, %c64_i64 : i64
      cal.set(%1 : !cal.state_ref<i64>, %3 : i64)
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %4 = memref.load %alloca[%arg4] : memref<64xi24>
        fifo.push(%arg2 : !fifo.input_port<i24>, %4 : i24)
      }
    }
    
    cal.action "Cr" priority=2
    {
      %alloca = memref.alloca() : memref<64xi24>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %4 = fifo.pop(%arg0 : !fifo.output_port<i24>) : i24
        memref.store %4, %alloca[%arg4] : memref<64xi24>
      }
      %2 = cal.get(%1 : !cal.state_ref<i64>) : i64
      %3 = arith.addi %2, %c64_i64 : i64
      cal.set(%1 : !cal.state_ref<i64>, %3 : i64)
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %4 = memref.load %alloca[%arg4] : memref<64xi24>
        fifo.push(%arg3 : !fifo.input_port<i24>, %4 : i24)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel__Merger420()
    in_names ["Y", "Cb", "Cr"]
    out_names ["YCbCr"]
    ports_in (
      %arg0: !fifo.output_port<i8>, 
      %arg1: !fifo.output_port<i8>, 
      %arg2: !fifo.output_port<i8>
    )
    ports_out (
      %arg3: !fifo.input_port<i8>
    )
  {
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%0 : !cal.state_ref<i64>, %c0_i64 : i64)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.fsm {
      cal.state @Y0 {
        cal.transition action("Y") -> @Y1
      } {initial}
      cal.state @Cb {
        cal.transition action("Cb") -> @Cr
      }
      cal.state @Cr {
        cal.transition action("Cr") -> @Y0
      }
      cal.state @Y1 {
        cal.transition action("Y") -> @Y2
      }
      cal.state @Y2 {
        cal.transition action("Y") -> @Y3
      }
      cal.state @Y3 {
        cal.transition action("Y") -> @Cb
      }
    }
    cal.action "Y" priority=2
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %5 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
        memref.store %5, %alloca[%arg4] : memref<64xi8>
      }
      %3 = cal.get(%0 : !cal.state_ref<i64>) : i64
      %4 = arith.addi %3, %c64_i64 : i64
      cal.set(%0 : !cal.state_ref<i64>, %4 : i64)
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %5 = memref.load %alloca[%arg4] : memref<64xi8>
        fifo.push(%arg3 : !fifo.input_port<i8>, %5 : i8)
      }
    }
    
    cal.action "Cb" priority=2
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %3 = fifo.pop(%arg1 : !fifo.output_port<i8>) : i8
        memref.store %3, %alloca[%arg4] : memref<64xi8>
      }
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %3 = memref.load %alloca[%arg4] : memref<64xi8>
        fifo.push(%arg3 : !fifo.input_port<i8>, %3 : i8)
      }
    }
    
    cal.action "Cr" priority=2
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %3 = fifo.pop(%arg2 : !fifo.output_port<i8>) : i8
        memref.store %3, %alloca[%arg4] : memref<64xi8>
      }
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %3 = memref.load %alloca[%arg4] : memref<64xi8>
        fifo.push(%arg3 : !fifo.input_port<i8>, %3 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_parser__ParseJPEG()
    in_names ["Byte"]
    out_names ["Data", "QT", "HT", "SOI"]
    ports_in (
      %arg0: !fifo.output_port<i8>
    )
    ports_out (
      %arg1: !fifo.input_port<i8>, 
      %arg2: !fifo.input_port<i8>, 
      %arg3: !fifo.input_port<i8>, 
      %arg4: !fifo.input_port<i16>
    )
  {
    %c-1_i8 = arith.constant -1 : i8
    %c3 = arith.constant 3 : index
    %c0_i8 = arith.constant 0 : i8
    %c-1_i32 = arith.constant -1 : i32
    %c217_i32 = arith.constant 217 : i32
    %c218_i32 = arith.constant 218 : i32
    %c196_i32 = arith.constant 196 : i32
    %c15 = arith.constant 15 : index
    %c192_i32 = arith.constant 192 : i32
    %c219_i32 = arith.constant 219 : i32
    %c254_i32 = arith.constant 254 : i32
    %c239_i32 = arith.constant 239 : i32
    %c224_i32 = arith.constant 224 : i32
    %c4_i32 = arith.constant 4 : i32
    %c8_i32 = arith.constant 8 : i32
    %c4 = arith.constant 4 : index
    %false = arith.constant false
    %c255_i32 = arith.constant 255 : i32
    %c2_i32 = arith.constant 2 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c-1_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
    %3 = cal.create_state_var<i8> : !cal.state_ref<i8>
    cal.set(%3 : !cal.state_ref<i8>, %c0_i8 : i8)
    cal.fsm {
      cal.state @wait_SOI {
        cal.transition action("SOI") -> @wait_marker
      } {initial}
      cal.state @handle_marker {
        cal.transition action("APPn") -> @skip_bytes
        cal.transition action("COMM") -> @skip_bytes
        cal.transition action("DQT") -> @wait_DQT
        cal.transition action("SOF0") -> @wait_marker
        cal.transition action("DHT") -> @wait_DHT
        cal.transition action("SOS") -> @wait_scan_header
      }
      cal.state @is_stuffing {
        cal.transition action("stuffing") -> @wait_scan_data
        cal.transition action("EOI") -> @padding
      }
      cal.state @padding {
        cal.transition action("padding16") -> @wait_SOI
      }
      cal.state @skip_bytes {
        cal.transition action("skip") -> @skip_bytes
        cal.transition action("done") -> @wait_marker
      }
      cal.state @wait_DHT {
        cal.transition action("send_DHT") -> @wait_DHT
        cal.transition action("done") -> @wait_marker
      }
      cal.state @wait_DQT {
        cal.transition action("send_DQT") -> @wait_DQT
        cal.transition action("done") -> @wait_marker
      }
      cal.state @wait_marker {
        cal.transition action("receive_marker") -> @handle_marker
      }
      cal.state @wait_scan_data {
        cal.transition action("scan_data") -> @wait_scan_data
        cal.transition action("receive_FF") -> @is_stuffing
      }
      cal.state @wait_scan_header {
        cal.transition action("skip") -> @wait_scan_header
        cal.transition action("done") -> @wait_scan_data
      }
    }
    cal.action "SOI" priority=16
    {
      scf.for %arg5 = %c0 to %c2 step %c1 {
        %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      }
      cal.set(%0 : !cal.state_ref<i32>, %c2_i32 : i32)
      cal.set(%1 : !cal.state_ref<i32>, %c-1_i32 : i32)
      cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
      cal.set(%3 : !cal.state_ref<i8>, %c0_i8 : i8)
    }
    
    cal.action "receive_marker" priority=16
    {
      %alloca = memref.alloca() : memref<4xi8>
      scf.for %arg5 = %c0 to %c4 step %c1 {
        %14 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
        memref.store %14, %alloca[%arg5] : memref<4xi8>
      }
      %4 = memref.load %alloca[%c3] : memref<4xi8>
      %5 = memref.load %alloca[%c2] : memref<4xi8>
      %6 = arith.extui %5 : i8 to i32
      %7 = arith.shli %6, %c8_i32 : i32
      %8 = arith.extui %4 : i8 to i32
      %9 = arith.addi %8, %7 : i32
      %10 = arith.subi %9, %c2_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %10 : i32)
      %11 = memref.load %alloca[%c1] : memref<4xi8>
      cal.set(%3 : !cal.state_ref<i8>, %11 : i8)
      %12 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %13 = arith.addi %12, %c4_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %13 : i32)
    }
    
    cal.action "skip" priority=16
    {
      cal.predicate {
        %9 = cal.get(%1 : !cal.state_ref<i32>) : i32
        %10 = arith.cmpi ne, %9, %c0_i32 : i32
        cal.predicate_result %10 : i1
      }
      %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.subi %5, %c1_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %6 : i32)
      %7 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %8 = arith.addi %7, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %8 : i32)
    }
    
    cal.action "done" priority=16
    {
      cal.predicate {
        %4 = cal.get(%1 : !cal.state_ref<i32>) : i32
        %5 = arith.cmpi eq, %4, %c0_i32 : i32
        cal.predicate_result %5 : i1
      }
      cal.set(%1 : !cal.state_ref<i32>, %c-1_i32 : i32)
    }
    
    cal.action "APPn" priority=16
    {
      cal.predicate {
        %4 = cal.get(%3 : !cal.state_ref<i8>) : i8
        %5 = arith.extui %4 : i8 to i32
        %6 = arith.cmpi uge, %5, %c224_i32 : i32
        %7 = arith.cmpi ule, %5, %c239_i32 : i32
        %8 = arith.select %6, %7, %false : i1
        cal.predicate_result %8 : i1
      }
    }
    
    cal.action "COMM" priority=16
    {
      cal.predicate {
        %4 = cal.get(%3 : !cal.state_ref<i8>) : i8
        %5 = arith.extui %4 : i8 to i32
        %6 = arith.cmpi eq, %5, %c254_i32 : i32
        cal.predicate_result %6 : i1
      }
    }
    
    cal.action "DQT" priority=16
    {
      cal.predicate {
        %7 = cal.get(%3 : !cal.state_ref<i8>) : i8
        %8 = arith.extui %7 : i8 to i32
        %9 = arith.cmpi eq, %8, %c219_i32 : i32
        cal.predicate_result %9 : i1
      }
      %4 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %4, %5 : i32
      cal.set(%0 : !cal.state_ref<i32>, %6 : i32)
    }
    
    cal.action "send_DQT" priority=16
    {
      cal.predicate {
        %7 = cal.get(%1 : !cal.state_ref<i32>) : i32
        %8 = arith.cmpi ne, %7, %c0_i32 : i32
        cal.predicate_result %8 : i1
      }
      %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.subi %5, %c1_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %6 : i32)
      fifo.push(%arg2 : !fifo.input_port<i8>, %4 : i8)
    }
    
    cal.action "SOF0" priority=16
    {
      cal.predicate {
        %20 = cal.get(%3 : !cal.state_ref<i8>) : i8
        %21 = arith.extui %20 : i8 to i32
        %22 = arith.cmpi eq, %21, %c192_i32 : i32
        cal.predicate_result %22 : i1
      }
      %alloca = memref.alloca() : memref<15xi8>
      scf.for %arg5 = %c0 to %c15 step %c1 {
        %20 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
        memref.store %20, %alloca[%arg5] : memref<15xi8>
      }
      %4 = memref.load %alloca[%c1] : memref<15xi8>
      %5 = arith.extui %4 : i8 to i32
      %6 = arith.shli %5, %c8_i32 : i32
      %7 = memref.load %alloca[%c2] : memref<15xi8>
      %8 = arith.extui %7 : i8 to i32
      %9 = arith.addi %6, %8 : i32
      %10 = memref.load %alloca[%c3] : memref<15xi8>
      %11 = arith.extui %10 : i8 to i32
      %12 = arith.shli %11, %c8_i32 : i32
      %13 = memref.load %alloca[%c4] : memref<15xi8>
      %14 = arith.extui %13 : i8 to i32
      %15 = arith.addi %12, %14 : i32
      %16 = arith.shrsi %15, %c4_i32 : i32
      %17 = arith.trunci %16 : i32 to i16
      fifo.push(%arg4 : !fifo.input_port<i16>, %17 : i16)
      %18 = arith.shrsi %9, %c4_i32 : i32
      %19 = arith.trunci %18 : i32 to i16
      fifo.push(%arg4 : !fifo.input_port<i16>, %19 : i16)
    }
    
    cal.action "DHT" priority=16
    {
      cal.predicate {
        %4 = cal.get(%3 : !cal.state_ref<i8>) : i8
        %5 = arith.extui %4 : i8 to i32
        %6 = arith.cmpi eq, %5, %c196_i32 : i32
        cal.predicate_result %6 : i1
      }
    }
    
    cal.action "send_DHT" priority=16
    {
      cal.predicate {
        %9 = cal.get(%1 : !cal.state_ref<i32>) : i32
        %10 = arith.cmpi ne, %9, %c0_i32 : i32
        cal.predicate_result %10 : i1
      }
      %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.subi %5, %c1_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %6 : i32)
      %7 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %8 = arith.addi %7, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %8 : i32)
      fifo.push(%arg3 : !fifo.input_port<i8>, %4 : i8)
    }
    
    cal.action "SOS" priority=16
    {
      cal.predicate {
        %4 = cal.get(%3 : !cal.state_ref<i8>) : i8
        %5 = arith.extui %4 : i8 to i32
        %6 = arith.cmpi eq, %5, %c218_i32 : i32
        cal.predicate_result %6 : i1
      }
    }
    
    cal.action "scan_data" priority=16
    {
      cal.predicate {
        %9 = fifo.peek(%arg0 : !fifo.output_port<i8>, %c0 : index) : i8
        %10 = arith.extui %9 : i8 to i32
        %11 = arith.cmpi ne, %10, %c255_i32 : i32
        cal.predicate_result %11 : i1
      }
      %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %5, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %6 : i32)
      %7 = cal.get(%2 : !cal.state_ref<i32>) : i32
      %8 = arith.addi %7, %c1_i32 : i32
      cal.set(%2 : !cal.state_ref<i32>, %8 : i32)
      fifo.push(%arg1 : !fifo.input_port<i8>, %4 : i8)
    }
    
    cal.action "receive_FF" priority=16
    {
      cal.predicate {
        %7 = fifo.peek(%arg0 : !fifo.output_port<i8>, %c0 : index) : i8
        %8 = arith.extui %7 : i8 to i32
        %9 = arith.cmpi eq, %8, %c255_i32 : i32
        cal.predicate_result %9 : i1
      }
      %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %5, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %6 : i32)
    }
    
    cal.action "stuffing" priority=16
    {
      cal.predicate {
        %9 = fifo.peek(%arg0 : !fifo.output_port<i8>, %c0 : index) : i8
        %10 = arith.extui %9 : i8 to i32
        %11 = arith.cmpi eq, %10, %c0_i32 : i32
        cal.predicate_result %11 : i1
      }
      %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      %5 = cal.get(%2 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %5, %c1_i32 : i32
      cal.set(%2 : !cal.state_ref<i32>, %6 : i32)
      %7 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %8 = arith.addi %7, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %8 : i32)
      fifo.push(%arg1 : !fifo.input_port<i8>, %c-1_i8 : i8)
    }
    
    cal.action "EOI" priority=16
    {
      cal.predicate {
        %7 = fifo.peek(%arg0 : !fifo.output_port<i8>, %c0 : index) : i8
        %8 = arith.extui %7 : i8 to i32
        %9 = arith.cmpi eq, %8, %c217_i32 : i32
        cal.predicate_result %9 : i1
      }
      %4 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
      %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %5, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %6 : i32)
    }
    
    cal.action "padding16" priority=16
    {
      fifo.push(%arg1 : !fifo.input_port<i8>, %c0_i8 : i8)
      fifo.push(%arg1 : !fifo.input_port<i8>, %c0_i8 : i8)
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_parser__SplitQT()
    in_names ["QT"]
    out_names ["QT_Y", "QT_UV_1", "QT_UV_2"]
    ports_in (
      %arg0: !fifo.output_port<i8>
    )
    ports_out (
      %arg1: !fifo.input_port<i8>, 
      %arg2: !fifo.input_port<i8>, 
      %arg3: !fifo.input_port<i8>
    )
  {
    %c1 = arith.constant 1 : index
    %c64 = arith.constant 64 : index
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %c0 = arith.constant 0 : index
    cal.fsm {
      cal.state @wait_dest_ID {
        cal.transition action("Luminance") -> @wait_Luminance
        cal.transition action("Chrominance") -> @wait_Chrominance
      } {initial}
      cal.state @wait_Chrominance {
        cal.transition action("receive_Chrominance") -> @wait_dest_ID
      }
      cal.state @wait_Luminance {
        cal.transition action("receive_Luminance") -> @wait_dest_ID
      }
    }
    cal.action "Luminance" priority=3
    {
      cal.predicate {
        %1 = fifo.peek(%arg0 : !fifo.output_port<i8>, %c0 : index) : i8
        %2 = arith.extui %1 : i8 to i32
        %3 = arith.cmpi eq, %2, %c0_i32 : i32
        cal.predicate_result %3 : i1
      }
      %0 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
    }
    
    cal.action "Chrominance" priority=3
    {
      cal.predicate {
        %1 = fifo.peek(%arg0 : !fifo.output_port<i8>, %c0 : index) : i8
        %2 = arith.extui %1 : i8 to i32
        %3 = arith.cmpi eq, %2, %c1_i32 : i32
        cal.predicate_result %3 : i1
      }
      %0 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
    }
    
    cal.action "receive_Luminance" priority=3
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %0 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
        memref.store %0, %alloca[%arg4] : memref<64xi8>
      }
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %0 = memref.load %alloca[%arg4] : memref<64xi8>
        fifo.push(%arg1 : !fifo.input_port<i8>, %0 : i8)
      }
    }
    
    cal.action "receive_Chrominance" priority=3
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %0 = fifo.pop(%arg0 : !fifo.output_port<i8>) : i8
        memref.store %0, %alloca[%arg4] : memref<64xi8>
      }
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %0 = memref.load %alloca[%arg4] : memref<64xi8>
        fifo.push(%arg2 : !fifo.input_port<i8>, %0 : i8)
      }
      scf.for %arg4 = %c0 to %c64 step %c1 {
        %0 = memref.load %alloca[%arg4] : memref<64xi8>
        fifo.push(%arg3 : !fifo.input_port<i8>, %0 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_io__Source__v__frames_300(%arg0: i32)
    out_names ["Out"]
    ports_out (
      %arg1: !fifo.input_port<i8>
    )
  {
    %c27 = arith.constant 27 : index
    %c64 = arith.constant 64 : index
    %c1000_i32 = arith.constant 1000 : i32
    %false = arith.constant false
    %c3867_i32 = arith.constant 3867 : i32
    %c0 = arith.constant 0 : index
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c3840_i32 = arith.constant 3840 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c0_i32 : i32)
    %2 = cal.create_state_var<memref<3867xi8>> : !cal.state_ref<memref<3867xi8>>
    %3 = cal.get(%2 : !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
    %4 = memref.get_global @__cmr_3 : memref<3867xi8>
    memref.copy %4, %3 : memref<3867xi8> to memref<3867xi8>
    cal.action "$untagged0" priority=2
    {
      cal.predicate {
        %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %6 = arith.cmpi ult, %5, %c3840_i32 : i32
        cal.predicate_result %6 : i1
      }
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg2 = %c0 to %c64 step %c1 {
        %5 = cal.get(%2 : !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
        %6 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %7 = arith.index_cast %6 : i32 to index
        %8 = memref.load %5[%7] : memref<3867xi8>
        memref.store %8, %alloca[%arg2] : memref<64xi8>
        %9 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %10 = arith.addi %9, %c1_i32 : i32
        cal.set(%0 : !cal.state_ref<i32>, %10 : i32)
      }
      scf.for %arg2 = %c0 to %c64 step %c1 {
        %5 = memref.load %alloca[%arg2] : memref<64xi8>
        fifo.push(%arg1 : !fifo.input_port<i8>, %5 : i8)
      }
    }
    
    cal.action "$untagged1" priority=2
    {
      cal.predicate {
        %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %6 = arith.cmpi uge, %5, %c3840_i32 : i32
        %7 = arith.cmpi ult, %5, %c3867_i32 : i32
        %8 = arith.select %6, %7, %false : i1
        cal.predicate_result %8 : i1
      }
      %alloca = memref.alloca() : memref<27xi8>
      scf.for %arg2 = %c0 to %c27 step %c1 {
        %5 = cal.get(%2 : !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
        %6 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %7 = arith.index_cast %6 : i32 to index
        %8 = memref.load %5[%7] : memref<3867xi8>
        memref.store %8, %alloca[%arg2] : memref<27xi8>
        %9 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %10 = arith.addi %9, %c1_i32 : i32
        cal.set(%0 : !cal.state_ref<i32>, %10 : i32)
      }
      scf.for %arg2 = %c0 to %c27 step %c1 {
        %5 = memref.load %alloca[%arg2] : memref<27xi8>
        fifo.push(%arg1 : !fifo.input_port<i8>, %5 : i8)
      }
    }
    
    cal.action "$untagged2" priority=2
    {
      cal.predicate {
        %12 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %13 = arith.cmpi eq, %12, %c3867_i32 : i32
        %14 = cal.get(%1 : !cal.state_ref<i32>) : i32
        %15 = arith.cmpi ult, %14, %arg0 : i32
        %16 = arith.select %13, %15, %false : i1
        cal.predicate_result %16 : i1
      }
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %5, %c1_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %6 : i32)
      %7 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %8 = arith.remui %7, %c1000_i32 : i32
      %9 = arith.cmpi eq, %8, %c0_i32 : i32
      scf.if %9 {
        %12 = cal.get(%1 : !cal.state_ref<i32>) : i32
        fifo.print("Finished sending frame %u\0A\00", %12) : (i32)
      }
      %10 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %11 = arith.cmpi ult, %10, %arg0 : i32
      scf.if %11 {
        cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_dequant__Dequant__v__mb_4(%arg0: i32)
    in_names ["SOI", "QT", "Block"]
    out_names ["Out"]
    ports_in (
      %arg1: !fifo.output_port<i16>, 
      %arg2: !fifo.output_port<i8>, 
      %arg3: !fifo.output_port<i24>
    )
    ports_out (
      %arg4: !fifo.input_port<i13>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<memref<64xi6>> : !cal.state_ref<memref<64xi6>>
    %1 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
    %2 = memref.get_global @__cmr_4 : memref<64xi6>
    memref.copy %2, %1 : memref<64xi6> to memref<64xi6>
    %3 = cal.create_state_var<memref<64xi8>> : !cal.state_ref<memref<64xi8>>
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c0_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.fsm {
      cal.state @s0 {
        cal.transition action("get_SOI") -> @s1
      } {initial}
      cal.state @s1 {
        cal.transition action("receive_QT") -> @s2
      }
      cal.state @s2 {
        cal.transition action("receive_block") -> @s2
        cal.transition action("eoi") -> @s0
      }
    }
    cal.action "get_SOI" priority=3
    {
      %6 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %7 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %8 = arith.extsi %arg0 : i32 to i64
      %9 = arith.extui %6 : i16 to i64
      %10 = arith.muli %8, %9 : i64
      %11 = arith.extui %7 : i16 to i64
      %12 = arith.muli %10, %11 : i64
      %13 = arith.trunci %12 : i64 to i32
      cal.set(%4 : !cal.state_ref<i32>, %13 : i32)
      cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    }
    
    cal.action "receive_QT" priority=3
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = fifo.pop(%arg2 : !fifo.output_port<i8>) : i8
        memref.store %7, %alloca[%arg5] : memref<64xi8>
      }
      %6 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = memref.load %alloca[%arg5] : memref<64xi8>
        memref.store %7, %6[%arg5] : memref<64xi8>
      }
    }
    
    cal.action "receive_block" priority=2
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi24>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = fifo.pop(%arg3 : !fifo.output_port<i24>) : i24
        memref.store %8, %alloca_0[%arg5] : memref<64xi24>
      }
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = memref.load %alloca_0[%arg5] : memref<64xi24>
        %9 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
        %10 = memref.load %9[%arg5] : memref<64xi8>
        %11 = arith.extsi %8 : i24 to i48
        %12 = arith.extsi %10 : i8 to i48
        %13 = arith.muli %11, %12 : i48
        %14 = arith.trunci %13 : i48 to i32
        memref.store %14, %alloca[%arg5] : memref<64xi32>
      }
      %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %7 = arith.addi %6, %c1_i32 : i32
      cal.set(%5 : !cal.state_ref<i32>, %7 : i32)
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
        %9 = memref.load %8[%arg5] : memref<64xi6>
        %10 = arith.extui %9 : i6 to i32
        %11 = arith.index_cast %10 : i32 to index
        %12 = memref.load %alloca[%11] : memref<64xi32>
        %13 = arith.trunci %12 : i32 to i13
        fifo.push(%arg4 : !fifo.input_port<i13>, %13 : i13)
      }
    }
    
    cal.action "eoi" priority=3
    {
      cal.predicate {
        %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
        %7 = cal.get(%4 : !cal.state_ref<i32>) : i32
        %8 = arith.cmpi eq, %6, %7 : i32
        cal.predicate_result %8 : i1
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_dequant__Dequant__v__mb_1(%arg0: i32)
    in_names ["SOI", "QT", "Block"]
    out_names ["Out"]
    ports_in (
      %arg1: !fifo.output_port<i16>, 
      %arg2: !fifo.output_port<i8>, 
      %arg3: !fifo.output_port<i24>
    )
    ports_out (
      %arg4: !fifo.input_port<i13>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<memref<64xi6>> : !cal.state_ref<memref<64xi6>>
    %1 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
    %2 = memref.get_global @__cmr_4 : memref<64xi6>
    memref.copy %2, %1 : memref<64xi6> to memref<64xi6>
    %3 = cal.create_state_var<memref<64xi8>> : !cal.state_ref<memref<64xi8>>
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c0_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.fsm {
      cal.state @s0 {
        cal.transition action("get_SOI") -> @s1
      } {initial}
      cal.state @s1 {
        cal.transition action("receive_QT") -> @s2
      }
      cal.state @s2 {
        cal.transition action("receive_block") -> @s2
        cal.transition action("eoi") -> @s0
      }
    }
    cal.action "get_SOI" priority=3
    {
      %6 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %7 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %8 = arith.extsi %arg0 : i32 to i64
      %9 = arith.extui %6 : i16 to i64
      %10 = arith.muli %8, %9 : i64
      %11 = arith.extui %7 : i16 to i64
      %12 = arith.muli %10, %11 : i64
      %13 = arith.trunci %12 : i64 to i32
      cal.set(%4 : !cal.state_ref<i32>, %13 : i32)
      cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    }
    
    cal.action "receive_QT" priority=3
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = fifo.pop(%arg2 : !fifo.output_port<i8>) : i8
        memref.store %7, %alloca[%arg5] : memref<64xi8>
      }
      %6 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = memref.load %alloca[%arg5] : memref<64xi8>
        memref.store %7, %6[%arg5] : memref<64xi8>
      }
    }
    
    cal.action "receive_block" priority=2
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi24>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = fifo.pop(%arg3 : !fifo.output_port<i24>) : i24
        memref.store %8, %alloca_0[%arg5] : memref<64xi24>
      }
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = memref.load %alloca_0[%arg5] : memref<64xi24>
        %9 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
        %10 = memref.load %9[%arg5] : memref<64xi8>
        %11 = arith.extsi %8 : i24 to i48
        %12 = arith.extsi %10 : i8 to i48
        %13 = arith.muli %11, %12 : i48
        %14 = arith.trunci %13 : i48 to i32
        memref.store %14, %alloca[%arg5] : memref<64xi32>
      }
      %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %7 = arith.addi %6, %c1_i32 : i32
      cal.set(%5 : !cal.state_ref<i32>, %7 : i32)
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
        %9 = memref.load %8[%arg5] : memref<64xi6>
        %10 = arith.extui %9 : i6 to i32
        %11 = arith.index_cast %10 : i32 to index
        %12 = memref.load %alloca[%11] : memref<64xi32>
        %13 = arith.trunci %12 : i32 to i13
        fifo.push(%arg4 : !fifo.input_port<i13>, %13 : i13)
      }
    }
    
    cal.action "eoi" priority=3
    {
      cal.predicate {
        %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
        %7 = cal.get(%4 : !cal.state_ref<i32>) : i32
        %8 = arith.cmpi eq, %6, %7 : i32
        cal.predicate_result %8 : i1
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_dyn(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i13>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c4096_i32 = arith.constant 4096 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c2528_i32 = arith.constant 2528 : i32
    %c2718_i32 = arith.constant 2718 : i32
    %c2923_i32 = arith.constant 2923 : i32
    %c1788_i32 = arith.constant 1788 : i32
    %c1922_i32 = arith.constant 1922 : i32
    %c1264_i32 = arith.constant 1264 : i32
    %c1609_i32 = arith.constant 1609 : i32
    %c1730_i32 = arith.constant 1730 : i32
    %c1138_i32 = arith.constant 1138 : i32
    %c1024_i32 = arith.constant 1024 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c1024_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c1138_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c1730_i32 : i32)
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c1609_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c1264_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c1922_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c1788_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c2923_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c2718_i32 : i32)
    %10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%10 : !cal.state_ref<i32>, %c2528_i32 : i32)
    %11 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %12 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %13 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %13, %12 : memref<64xi16> to memref<64xi16>
    %14 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%14 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "scale" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi13>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = fifo.pop(%arg1 : !fifo.output_port<i13>) : i13
        memref.store %19, %alloca_0[%arg3] : memref<64xi13>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca_0[%arg3] : memref<64xi13>
        %20 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %21 = memref.load %20[%arg3] : memref<64xi16>
        %22 = arith.extsi %19 : i13 to i32
        %23 = arith.extsi %21 : i16 to i32
        %24 = arith.muli %22, %23 : i32
        memref.store %24, %alloca[%arg3] : memref<64xi32>
      }
      %15 = memref.load %alloca[%c0] : memref<64xi32>
      %16 = arith.addi %15, %c4096_i32 : i32
      memref.store %16, %alloca[%c0] : memref<64xi32>
      %17 = cal.get(%14 : !cal.state_ref<i64>) : i64
      %18 = arith.addi %17, %c64_i64 : i64
      cal.set(%14 : !cal.state_ref<i64>, %18 : i64)
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca[%arg3] : memref<64xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %19 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_dyn(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c4_i32 = arith.constant 4 : i32
    %c2_i32 = arith.constant 2 : i32
    %c9_i32 = arith.constant 9 : i32
    %c11_i32 = arith.constant 11 : i32
    %c5_i32 = arith.constant 5 : i32
    %c3_i32 = arith.constant 3 : i32
    %c7_i32 = arith.constant 7 : i32
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<8xi32>
      %alloca_0 = memref.alloca() : memref<8xi32>
      %alloca_1 = memref.alloca() : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %100, %alloca_1[%arg3] : memref<8xi32>
      }
      memref.copy %alloca_1, %alloca_0 : memref<8xi32> to memref<8xi32>
      %2 = memref.load %alloca_0[%c1] : memref<8xi32>
      %3 = memref.load %alloca_0[%c7] : memref<8xi32>
      %4 = arith.addi %2, %3 : i32
      %5 = arith.subi %2, %3 : i32
      %6 = memref.load %alloca_0[%c3] : memref<8xi32>
      %7 = arith.addi %4, %6 : i32
      memref.store %7, %alloca_0[%c1] : memref<8xi32>
      %8 = memref.load %alloca_0[%c3] : memref<8xi32>
      %9 = arith.subi %4, %8 : i32
      memref.store %9, %alloca_0[%c3] : memref<8xi32>
      %10 = memref.load %alloca_0[%c5] : memref<8xi32>
      %11 = arith.addi %5, %10 : i32
      memref.store %11, %alloca_0[%c7] : memref<8xi32>
      %12 = memref.load %alloca_0[%c5] : memref<8xi32>
      %13 = arith.subi %5, %12 : i32
      memref.store %13, %alloca_0[%c5] : memref<8xi32>
      %14 = memref.load %alloca_0[%c3] : memref<8xi32>
      %15 = arith.shrsi %14, %c3_i32 : i32
      %16 = arith.shrsi %14, %c7_i32 : i32
      %17 = arith.subi %15, %16 : i32
      %18 = arith.subi %14, %17 : i32
      %19 = arith.shrsi %14, %c11_i32 : i32
      %20 = arith.subi %17, %19 : i32
      %21 = arith.shrsi %20, %c1_i32 : i32
      %22 = arith.addi %17, %21 : i32
      %23 = memref.load %alloca_0[%c5] : memref<8xi32>
      %24 = arith.shrsi %23, %c3_i32 : i32
      %25 = arith.shrsi %23, %c7_i32 : i32
      %26 = arith.subi %24, %25 : i32
      %27 = arith.subi %23, %26 : i32
      %28 = arith.shrsi %23, %c11_i32 : i32
      %29 = arith.subi %26, %28 : i32
      %30 = arith.shrsi %29, %c1_i32 : i32
      %31 = arith.addi %26, %30 : i32
      %32 = arith.subi %18, %31 : i32
      memref.store %32, %alloca_0[%c3] : memref<8xi32>
      %33 = arith.addi %27, %22 : i32
      memref.store %33, %alloca_0[%c5] : memref<8xi32>
      %34 = memref.load %alloca_0[%c1] : memref<8xi32>
      %35 = arith.shrsi %34, %c9_i32 : i32
      %36 = arith.subi %35, %34 : i32
      %37 = arith.shrsi %36, %c2_i32 : i32
      %38 = arith.subi %37, %36 : i32
      %39 = arith.shrsi %34, %c1_i32 : i32
      %40 = memref.load %alloca_0[%c7] : memref<8xi32>
      %41 = arith.shrsi %40, %c9_i32 : i32
      %42 = arith.subi %41, %40 : i32
      %43 = arith.shrsi %42, %c2_i32 : i32
      %44 = arith.subi %43, %42 : i32
      %45 = arith.shrsi %40, %c1_i32 : i32
      %46 = arith.addi %38, %45 : i32
      memref.store %46, %alloca_0[%c1] : memref<8xi32>
      %47 = arith.subi %44, %39 : i32
      memref.store %47, %alloca_0[%c7] : memref<8xi32>
      %48 = memref.load %alloca_0[%c2] : memref<8xi32>
      %49 = arith.shrsi %48, %c5_i32 : i32
      %50 = arith.addi %48, %49 : i32
      %51 = arith.shrsi %50, %c2_i32 : i32
      %52 = arith.shrsi %48, %c4_i32 : i32
      %53 = arith.addi %51, %52 : i32
      %54 = arith.subi %50, %51 : i32
      %55 = memref.load %alloca_0[%c6] : memref<8xi32>
      %56 = arith.shrsi %55, %c5_i32 : i32
      %57 = arith.addi %55, %56 : i32
      %58 = arith.shrsi %57, %c2_i32 : i32
      %59 = arith.shrsi %55, %c4_i32 : i32
      %60 = arith.addi %58, %59 : i32
      %61 = arith.subi %57, %58 : i32
      %62 = arith.subi %53, %61 : i32
      memref.store %62, %alloca_0[%c2] : memref<8xi32>
      %63 = arith.addi %60, %54 : i32
      memref.store %63, %alloca_0[%c6] : memref<8xi32>
      %64 = memref.load %alloca_0[%c0] : memref<8xi32>
      %65 = memref.load %alloca_0[%c4] : memref<8xi32>
      %66 = arith.addi %64, %65 : i32
      %67 = arith.subi %64, %65 : i32
      %68 = memref.load %alloca_0[%c6] : memref<8xi32>
      %69 = arith.addi %66, %68 : i32
      memref.store %69, %alloca_0[%c0] : memref<8xi32>
      %70 = memref.load %alloca_0[%c6] : memref<8xi32>
      %71 = arith.subi %66, %70 : i32
      memref.store %71, %alloca_0[%c6] : memref<8xi32>
      %72 = memref.load %alloca_0[%c2] : memref<8xi32>
      %73 = arith.addi %67, %72 : i32
      memref.store %73, %alloca_0[%c4] : memref<8xi32>
      %74 = memref.load %alloca_0[%c2] : memref<8xi32>
      %75 = arith.subi %67, %74 : i32
      memref.store %75, %alloca_0[%c2] : memref<8xi32>
      %76 = memref.load %alloca_0[%c0] : memref<8xi32>
      %77 = memref.load %alloca_0[%c1] : memref<8xi32>
      %78 = arith.addi %76, %77 : i32
      memref.store %78, %alloca[%c0] : memref<8xi32>
      %79 = memref.load %alloca_0[%c4] : memref<8xi32>
      %80 = memref.load %alloca_0[%c5] : memref<8xi32>
      %81 = arith.addi %79, %80 : i32
      memref.store %81, %alloca[%c1] : memref<8xi32>
      %82 = memref.load %alloca_0[%c2] : memref<8xi32>
      %83 = memref.load %alloca_0[%c3] : memref<8xi32>
      %84 = arith.addi %82, %83 : i32
      memref.store %84, %alloca[%c2] : memref<8xi32>
      %85 = memref.load %alloca_0[%c6] : memref<8xi32>
      %86 = memref.load %alloca_0[%c7] : memref<8xi32>
      %87 = arith.addi %85, %86 : i32
      memref.store %87, %alloca[%c3] : memref<8xi32>
      %88 = memref.load %alloca_0[%c6] : memref<8xi32>
      %89 = memref.load %alloca_0[%c7] : memref<8xi32>
      %90 = arith.subi %88, %89 : i32
      memref.store %90, %alloca[%c4] : memref<8xi32>
      %91 = memref.load %alloca_0[%c2] : memref<8xi32>
      %92 = memref.load %alloca_0[%c3] : memref<8xi32>
      %93 = arith.subi %91, %92 : i32
      memref.store %93, %alloca[%c5] : memref<8xi32>
      %94 = memref.load %alloca_0[%c4] : memref<8xi32>
      %95 = memref.load %alloca_0[%c5] : memref<8xi32>
      %96 = arith.subi %94, %95 : i32
      memref.store %96, %alloca[%c6] : memref<8xi32>
      %97 = memref.load %alloca_0[%c0] : memref<8xi32>
      %98 = memref.load %alloca_0[%c1] : memref<8xi32>
      %99 = arith.subi %97, %98 : i32
      memref.store %99, %alloca[%c7] : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = memref.load %alloca[%arg3] : memref<8xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %100 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_dyn(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c8_i64 = arith.constant 8 : i64
    %c8 = arith.constant 8 : index
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %2 = arith.index_cast %arg3 : index to i32
        scf.for %arg4 = %c0 to %c8 step %c1 {
          %3 = arith.index_cast %arg4 : index to i32
          %4 = arith.extsi %3 : i32 to i64
          %5 = arith.muli %4, %c8_i64 : i64
          %6 = arith.extsi %2 : i32 to i64
          %7 = arith.addi %5, %6 : i64
          %8 = arith.index_cast %7 : i64 to index
          %9 = memref.load %alloca[%8] : memref<64xi32>
          fifo.push(%arg2 : !fifo.input_port<i32>, %9 : i32)
        }
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_dyn(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i8>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c255_i32 = arith.constant 255 : i32
    %c128_i32 = arith.constant 128 : i32
    %c13_i32 = arith.constant 13 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "shift" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = memref.load %alloca[%arg3] : memref<64xi32>
        %3 = arith.shrsi %2, %c13_i32 : i32
        %4 = arith.addi %3, %c128_i32 : i32
        %5 = arith.cmpi sgt, %4, %c255_i32 : i32
        %6 = scf.if %5 -> (i32) {
          scf.yield %c255_i32 : i32
        } else {
          %8 = arith.cmpi slt, %4, %c0_i32 : i32
          %9 = arith.select %8, %c0_i32, %4 : i32
          scf.yield %9 : i32
        }
        %7 = arith.trunci %6 : i32 to i8
        fifo.push(%arg2 : !fifo.input_port<i8>, %7 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_0(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i13>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c4096_i32 = arith.constant 4096 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c2528_i32 = arith.constant 2528 : i32
    %c2718_i32 = arith.constant 2718 : i32
    %c2923_i32 = arith.constant 2923 : i32
    %c1788_i32 = arith.constant 1788 : i32
    %c1922_i32 = arith.constant 1922 : i32
    %c1264_i32 = arith.constant 1264 : i32
    %c1609_i32 = arith.constant 1609 : i32
    %c1730_i32 = arith.constant 1730 : i32
    %c1138_i32 = arith.constant 1138 : i32
    %c1024_i32 = arith.constant 1024 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c1024_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c1138_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c1730_i32 : i32)
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c1609_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c1264_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c1922_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c1788_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c2923_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c2718_i32 : i32)
    %10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%10 : !cal.state_ref<i32>, %c2528_i32 : i32)
    %11 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %12 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %13 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %13, %12 : memref<64xi16> to memref<64xi16>
    %14 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%14 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "scale" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi13>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = fifo.pop(%arg1 : !fifo.output_port<i13>) : i13
        memref.store %19, %alloca_0[%arg3] : memref<64xi13>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca_0[%arg3] : memref<64xi13>
        %20 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %21 = memref.load %20[%arg3] : memref<64xi16>
        %22 = arith.extsi %19 : i13 to i32
        %23 = arith.extsi %21 : i16 to i32
        %24 = arith.muli %22, %23 : i32
        memref.store %24, %alloca[%arg3] : memref<64xi32>
      }
      %15 = memref.load %alloca[%c0] : memref<64xi32>
      %16 = arith.addi %15, %c4096_i32 : i32
      memref.store %16, %alloca[%c0] : memref<64xi32>
      %17 = cal.get(%14 : !cal.state_ref<i64>) : i64
      %18 = arith.addi %17, %c64_i64 : i64
      cal.set(%14 : !cal.state_ref<i64>, %18 : i64)
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca[%arg3] : memref<64xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %19 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c4_i32 = arith.constant 4 : i32
    %c2_i32 = arith.constant 2 : i32
    %c9_i32 = arith.constant 9 : i32
    %c11_i32 = arith.constant 11 : i32
    %c5_i32 = arith.constant 5 : i32
    %c3_i32 = arith.constant 3 : i32
    %c7_i32 = arith.constant 7 : i32
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<8xi32>
      %alloca_0 = memref.alloca() : memref<8xi32>
      %alloca_1 = memref.alloca() : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %100, %alloca_1[%arg3] : memref<8xi32>
      }
      memref.copy %alloca_1, %alloca_0 : memref<8xi32> to memref<8xi32>
      %2 = memref.load %alloca_0[%c1] : memref<8xi32>
      %3 = memref.load %alloca_0[%c7] : memref<8xi32>
      %4 = arith.addi %2, %3 : i32
      %5 = arith.subi %2, %3 : i32
      %6 = memref.load %alloca_0[%c3] : memref<8xi32>
      %7 = arith.addi %4, %6 : i32
      memref.store %7, %alloca_0[%c1] : memref<8xi32>
      %8 = memref.load %alloca_0[%c3] : memref<8xi32>
      %9 = arith.subi %4, %8 : i32
      memref.store %9, %alloca_0[%c3] : memref<8xi32>
      %10 = memref.load %alloca_0[%c5] : memref<8xi32>
      %11 = arith.addi %5, %10 : i32
      memref.store %11, %alloca_0[%c7] : memref<8xi32>
      %12 = memref.load %alloca_0[%c5] : memref<8xi32>
      %13 = arith.subi %5, %12 : i32
      memref.store %13, %alloca_0[%c5] : memref<8xi32>
      %14 = memref.load %alloca_0[%c3] : memref<8xi32>
      %15 = arith.shrsi %14, %c3_i32 : i32
      %16 = arith.shrsi %14, %c7_i32 : i32
      %17 = arith.subi %15, %16 : i32
      %18 = arith.subi %14, %17 : i32
      %19 = arith.shrsi %14, %c11_i32 : i32
      %20 = arith.subi %17, %19 : i32
      %21 = arith.shrsi %20, %c1_i32 : i32
      %22 = arith.addi %17, %21 : i32
      %23 = memref.load %alloca_0[%c5] : memref<8xi32>
      %24 = arith.shrsi %23, %c3_i32 : i32
      %25 = arith.shrsi %23, %c7_i32 : i32
      %26 = arith.subi %24, %25 : i32
      %27 = arith.subi %23, %26 : i32
      %28 = arith.shrsi %23, %c11_i32 : i32
      %29 = arith.subi %26, %28 : i32
      %30 = arith.shrsi %29, %c1_i32 : i32
      %31 = arith.addi %26, %30 : i32
      %32 = arith.subi %18, %31 : i32
      memref.store %32, %alloca_0[%c3] : memref<8xi32>
      %33 = arith.addi %27, %22 : i32
      memref.store %33, %alloca_0[%c5] : memref<8xi32>
      %34 = memref.load %alloca_0[%c1] : memref<8xi32>
      %35 = arith.shrsi %34, %c9_i32 : i32
      %36 = arith.subi %35, %34 : i32
      %37 = arith.shrsi %36, %c2_i32 : i32
      %38 = arith.subi %37, %36 : i32
      %39 = arith.shrsi %34, %c1_i32 : i32
      %40 = memref.load %alloca_0[%c7] : memref<8xi32>
      %41 = arith.shrsi %40, %c9_i32 : i32
      %42 = arith.subi %41, %40 : i32
      %43 = arith.shrsi %42, %c2_i32 : i32
      %44 = arith.subi %43, %42 : i32
      %45 = arith.shrsi %40, %c1_i32 : i32
      %46 = arith.addi %38, %45 : i32
      memref.store %46, %alloca_0[%c1] : memref<8xi32>
      %47 = arith.subi %44, %39 : i32
      memref.store %47, %alloca_0[%c7] : memref<8xi32>
      %48 = memref.load %alloca_0[%c2] : memref<8xi32>
      %49 = arith.shrsi %48, %c5_i32 : i32
      %50 = arith.addi %48, %49 : i32
      %51 = arith.shrsi %50, %c2_i32 : i32
      %52 = arith.shrsi %48, %c4_i32 : i32
      %53 = arith.addi %51, %52 : i32
      %54 = arith.subi %50, %51 : i32
      %55 = memref.load %alloca_0[%c6] : memref<8xi32>
      %56 = arith.shrsi %55, %c5_i32 : i32
      %57 = arith.addi %55, %56 : i32
      %58 = arith.shrsi %57, %c2_i32 : i32
      %59 = arith.shrsi %55, %c4_i32 : i32
      %60 = arith.addi %58, %59 : i32
      %61 = arith.subi %57, %58 : i32
      %62 = arith.subi %53, %61 : i32
      memref.store %62, %alloca_0[%c2] : memref<8xi32>
      %63 = arith.addi %60, %54 : i32
      memref.store %63, %alloca_0[%c6] : memref<8xi32>
      %64 = memref.load %alloca_0[%c0] : memref<8xi32>
      %65 = memref.load %alloca_0[%c4] : memref<8xi32>
      %66 = arith.addi %64, %65 : i32
      %67 = arith.subi %64, %65 : i32
      %68 = memref.load %alloca_0[%c6] : memref<8xi32>
      %69 = arith.addi %66, %68 : i32
      memref.store %69, %alloca_0[%c0] : memref<8xi32>
      %70 = memref.load %alloca_0[%c6] : memref<8xi32>
      %71 = arith.subi %66, %70 : i32
      memref.store %71, %alloca_0[%c6] : memref<8xi32>
      %72 = memref.load %alloca_0[%c2] : memref<8xi32>
      %73 = arith.addi %67, %72 : i32
      memref.store %73, %alloca_0[%c4] : memref<8xi32>
      %74 = memref.load %alloca_0[%c2] : memref<8xi32>
      %75 = arith.subi %67, %74 : i32
      memref.store %75, %alloca_0[%c2] : memref<8xi32>
      %76 = memref.load %alloca_0[%c0] : memref<8xi32>
      %77 = memref.load %alloca_0[%c1] : memref<8xi32>
      %78 = arith.addi %76, %77 : i32
      memref.store %78, %alloca[%c0] : memref<8xi32>
      %79 = memref.load %alloca_0[%c4] : memref<8xi32>
      %80 = memref.load %alloca_0[%c5] : memref<8xi32>
      %81 = arith.addi %79, %80 : i32
      memref.store %81, %alloca[%c1] : memref<8xi32>
      %82 = memref.load %alloca_0[%c2] : memref<8xi32>
      %83 = memref.load %alloca_0[%c3] : memref<8xi32>
      %84 = arith.addi %82, %83 : i32
      memref.store %84, %alloca[%c2] : memref<8xi32>
      %85 = memref.load %alloca_0[%c6] : memref<8xi32>
      %86 = memref.load %alloca_0[%c7] : memref<8xi32>
      %87 = arith.addi %85, %86 : i32
      memref.store %87, %alloca[%c3] : memref<8xi32>
      %88 = memref.load %alloca_0[%c6] : memref<8xi32>
      %89 = memref.load %alloca_0[%c7] : memref<8xi32>
      %90 = arith.subi %88, %89 : i32
      memref.store %90, %alloca[%c4] : memref<8xi32>
      %91 = memref.load %alloca_0[%c2] : memref<8xi32>
      %92 = memref.load %alloca_0[%c3] : memref<8xi32>
      %93 = arith.subi %91, %92 : i32
      memref.store %93, %alloca[%c5] : memref<8xi32>
      %94 = memref.load %alloca_0[%c4] : memref<8xi32>
      %95 = memref.load %alloca_0[%c5] : memref<8xi32>
      %96 = arith.subi %94, %95 : i32
      memref.store %96, %alloca[%c6] : memref<8xi32>
      %97 = memref.load %alloca_0[%c0] : memref<8xi32>
      %98 = memref.load %alloca_0[%c1] : memref<8xi32>
      %99 = arith.subi %97, %98 : i32
      memref.store %99, %alloca[%c7] : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = memref.load %alloca[%arg3] : memref<8xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %100 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_0(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c8_i64 = arith.constant 8 : i64
    %c8 = arith.constant 8 : index
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %2 = arith.index_cast %arg3 : index to i32
        scf.for %arg4 = %c0 to %c8 step %c1 {
          %3 = arith.index_cast %arg4 : index to i32
          %4 = arith.extsi %3 : i32 to i64
          %5 = arith.muli %4, %c8_i64 : i64
          %6 = arith.extsi %2 : i32 to i64
          %7 = arith.addi %5, %6 : i64
          %8 = arith.index_cast %7 : i64 to index
          %9 = memref.load %alloca[%8] : memref<64xi32>
          fifo.push(%arg2 : !fifo.input_port<i32>, %9 : i32)
        }
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_0(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i8>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c255_i32 = arith.constant 255 : i32
    %c128_i32 = arith.constant 128 : i32
    %c13_i32 = arith.constant 13 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "shift" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = memref.load %alloca[%arg3] : memref<64xi32>
        %3 = arith.shrsi %2, %c13_i32 : i32
        %4 = arith.addi %3, %c128_i32 : i32
        %5 = arith.cmpi sgt, %4, %c255_i32 : i32
        %6 = scf.if %5 -> (i32) {
          scf.yield %c255_i32 : i32
        } else {
          %8 = arith.cmpi slt, %4, %c0_i32 : i32
          %9 = arith.select %8, %c0_i32, %4 : i32
          scf.yield %9 : i32
        }
        %7 = arith.trunci %6 : i32 to i8
        fifo.push(%arg2 : !fifo.input_port<i8>, %7 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_1(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i13>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c4096_i32 = arith.constant 4096 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c2528_i32 = arith.constant 2528 : i32
    %c2718_i32 = arith.constant 2718 : i32
    %c2923_i32 = arith.constant 2923 : i32
    %c1788_i32 = arith.constant 1788 : i32
    %c1922_i32 = arith.constant 1922 : i32
    %c1264_i32 = arith.constant 1264 : i32
    %c1609_i32 = arith.constant 1609 : i32
    %c1730_i32 = arith.constant 1730 : i32
    %c1138_i32 = arith.constant 1138 : i32
    %c1024_i32 = arith.constant 1024 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c1024_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c1138_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c1730_i32 : i32)
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c1609_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c1264_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c1922_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c1788_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c2923_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c2718_i32 : i32)
    %10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%10 : !cal.state_ref<i32>, %c2528_i32 : i32)
    %11 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %12 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %13 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %13, %12 : memref<64xi16> to memref<64xi16>
    %14 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%14 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "scale" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi13>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = fifo.pop(%arg1 : !fifo.output_port<i13>) : i13
        memref.store %19, %alloca_0[%arg3] : memref<64xi13>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca_0[%arg3] : memref<64xi13>
        %20 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %21 = memref.load %20[%arg3] : memref<64xi16>
        %22 = arith.extsi %19 : i13 to i32
        %23 = arith.extsi %21 : i16 to i32
        %24 = arith.muli %22, %23 : i32
        memref.store %24, %alloca[%arg3] : memref<64xi32>
      }
      %15 = memref.load %alloca[%c0] : memref<64xi32>
      %16 = arith.addi %15, %c4096_i32 : i32
      memref.store %16, %alloca[%c0] : memref<64xi32>
      %17 = cal.get(%14 : !cal.state_ref<i64>) : i64
      %18 = arith.addi %17, %c64_i64 : i64
      cal.set(%14 : !cal.state_ref<i64>, %18 : i64)
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca[%arg3] : memref<64xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %19 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_1(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c4_i32 = arith.constant 4 : i32
    %c2_i32 = arith.constant 2 : i32
    %c9_i32 = arith.constant 9 : i32
    %c11_i32 = arith.constant 11 : i32
    %c5_i32 = arith.constant 5 : i32
    %c3_i32 = arith.constant 3 : i32
    %c7_i32 = arith.constant 7 : i32
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<8xi32>
      %alloca_0 = memref.alloca() : memref<8xi32>
      %alloca_1 = memref.alloca() : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %100, %alloca_1[%arg3] : memref<8xi32>
      }
      memref.copy %alloca_1, %alloca_0 : memref<8xi32> to memref<8xi32>
      %2 = memref.load %alloca_0[%c1] : memref<8xi32>
      %3 = memref.load %alloca_0[%c7] : memref<8xi32>
      %4 = arith.addi %2, %3 : i32
      %5 = arith.subi %2, %3 : i32
      %6 = memref.load %alloca_0[%c3] : memref<8xi32>
      %7 = arith.addi %4, %6 : i32
      memref.store %7, %alloca_0[%c1] : memref<8xi32>
      %8 = memref.load %alloca_0[%c3] : memref<8xi32>
      %9 = arith.subi %4, %8 : i32
      memref.store %9, %alloca_0[%c3] : memref<8xi32>
      %10 = memref.load %alloca_0[%c5] : memref<8xi32>
      %11 = arith.addi %5, %10 : i32
      memref.store %11, %alloca_0[%c7] : memref<8xi32>
      %12 = memref.load %alloca_0[%c5] : memref<8xi32>
      %13 = arith.subi %5, %12 : i32
      memref.store %13, %alloca_0[%c5] : memref<8xi32>
      %14 = memref.load %alloca_0[%c3] : memref<8xi32>
      %15 = arith.shrsi %14, %c3_i32 : i32
      %16 = arith.shrsi %14, %c7_i32 : i32
      %17 = arith.subi %15, %16 : i32
      %18 = arith.subi %14, %17 : i32
      %19 = arith.shrsi %14, %c11_i32 : i32
      %20 = arith.subi %17, %19 : i32
      %21 = arith.shrsi %20, %c1_i32 : i32
      %22 = arith.addi %17, %21 : i32
      %23 = memref.load %alloca_0[%c5] : memref<8xi32>
      %24 = arith.shrsi %23, %c3_i32 : i32
      %25 = arith.shrsi %23, %c7_i32 : i32
      %26 = arith.subi %24, %25 : i32
      %27 = arith.subi %23, %26 : i32
      %28 = arith.shrsi %23, %c11_i32 : i32
      %29 = arith.subi %26, %28 : i32
      %30 = arith.shrsi %29, %c1_i32 : i32
      %31 = arith.addi %26, %30 : i32
      %32 = arith.subi %18, %31 : i32
      memref.store %32, %alloca_0[%c3] : memref<8xi32>
      %33 = arith.addi %27, %22 : i32
      memref.store %33, %alloca_0[%c5] : memref<8xi32>
      %34 = memref.load %alloca_0[%c1] : memref<8xi32>
      %35 = arith.shrsi %34, %c9_i32 : i32
      %36 = arith.subi %35, %34 : i32
      %37 = arith.shrsi %36, %c2_i32 : i32
      %38 = arith.subi %37, %36 : i32
      %39 = arith.shrsi %34, %c1_i32 : i32
      %40 = memref.load %alloca_0[%c7] : memref<8xi32>
      %41 = arith.shrsi %40, %c9_i32 : i32
      %42 = arith.subi %41, %40 : i32
      %43 = arith.shrsi %42, %c2_i32 : i32
      %44 = arith.subi %43, %42 : i32
      %45 = arith.shrsi %40, %c1_i32 : i32
      %46 = arith.addi %38, %45 : i32
      memref.store %46, %alloca_0[%c1] : memref<8xi32>
      %47 = arith.subi %44, %39 : i32
      memref.store %47, %alloca_0[%c7] : memref<8xi32>
      %48 = memref.load %alloca_0[%c2] : memref<8xi32>
      %49 = arith.shrsi %48, %c5_i32 : i32
      %50 = arith.addi %48, %49 : i32
      %51 = arith.shrsi %50, %c2_i32 : i32
      %52 = arith.shrsi %48, %c4_i32 : i32
      %53 = arith.addi %51, %52 : i32
      %54 = arith.subi %50, %51 : i32
      %55 = memref.load %alloca_0[%c6] : memref<8xi32>
      %56 = arith.shrsi %55, %c5_i32 : i32
      %57 = arith.addi %55, %56 : i32
      %58 = arith.shrsi %57, %c2_i32 : i32
      %59 = arith.shrsi %55, %c4_i32 : i32
      %60 = arith.addi %58, %59 : i32
      %61 = arith.subi %57, %58 : i32
      %62 = arith.subi %53, %61 : i32
      memref.store %62, %alloca_0[%c2] : memref<8xi32>
      %63 = arith.addi %60, %54 : i32
      memref.store %63, %alloca_0[%c6] : memref<8xi32>
      %64 = memref.load %alloca_0[%c0] : memref<8xi32>
      %65 = memref.load %alloca_0[%c4] : memref<8xi32>
      %66 = arith.addi %64, %65 : i32
      %67 = arith.subi %64, %65 : i32
      %68 = memref.load %alloca_0[%c6] : memref<8xi32>
      %69 = arith.addi %66, %68 : i32
      memref.store %69, %alloca_0[%c0] : memref<8xi32>
      %70 = memref.load %alloca_0[%c6] : memref<8xi32>
      %71 = arith.subi %66, %70 : i32
      memref.store %71, %alloca_0[%c6] : memref<8xi32>
      %72 = memref.load %alloca_0[%c2] : memref<8xi32>
      %73 = arith.addi %67, %72 : i32
      memref.store %73, %alloca_0[%c4] : memref<8xi32>
      %74 = memref.load %alloca_0[%c2] : memref<8xi32>
      %75 = arith.subi %67, %74 : i32
      memref.store %75, %alloca_0[%c2] : memref<8xi32>
      %76 = memref.load %alloca_0[%c0] : memref<8xi32>
      %77 = memref.load %alloca_0[%c1] : memref<8xi32>
      %78 = arith.addi %76, %77 : i32
      memref.store %78, %alloca[%c0] : memref<8xi32>
      %79 = memref.load %alloca_0[%c4] : memref<8xi32>
      %80 = memref.load %alloca_0[%c5] : memref<8xi32>
      %81 = arith.addi %79, %80 : i32
      memref.store %81, %alloca[%c1] : memref<8xi32>
      %82 = memref.load %alloca_0[%c2] : memref<8xi32>
      %83 = memref.load %alloca_0[%c3] : memref<8xi32>
      %84 = arith.addi %82, %83 : i32
      memref.store %84, %alloca[%c2] : memref<8xi32>
      %85 = memref.load %alloca_0[%c6] : memref<8xi32>
      %86 = memref.load %alloca_0[%c7] : memref<8xi32>
      %87 = arith.addi %85, %86 : i32
      memref.store %87, %alloca[%c3] : memref<8xi32>
      %88 = memref.load %alloca_0[%c6] : memref<8xi32>
      %89 = memref.load %alloca_0[%c7] : memref<8xi32>
      %90 = arith.subi %88, %89 : i32
      memref.store %90, %alloca[%c4] : memref<8xi32>
      %91 = memref.load %alloca_0[%c2] : memref<8xi32>
      %92 = memref.load %alloca_0[%c3] : memref<8xi32>
      %93 = arith.subi %91, %92 : i32
      memref.store %93, %alloca[%c5] : memref<8xi32>
      %94 = memref.load %alloca_0[%c4] : memref<8xi32>
      %95 = memref.load %alloca_0[%c5] : memref<8xi32>
      %96 = arith.subi %94, %95 : i32
      memref.store %96, %alloca[%c6] : memref<8xi32>
      %97 = memref.load %alloca_0[%c0] : memref<8xi32>
      %98 = memref.load %alloca_0[%c1] : memref<8xi32>
      %99 = arith.subi %97, %98 : i32
      memref.store %99, %alloca[%c7] : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = memref.load %alloca[%arg3] : memref<8xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %100 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_1(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c8_i64 = arith.constant 8 : i64
    %c8 = arith.constant 8 : index
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %2 = arith.index_cast %arg3 : index to i32
        scf.for %arg4 = %c0 to %c8 step %c1 {
          %3 = arith.index_cast %arg4 : index to i32
          %4 = arith.extsi %3 : i32 to i64
          %5 = arith.muli %4, %c8_i64 : i64
          %6 = arith.extsi %2 : i32 to i64
          %7 = arith.addi %5, %6 : i64
          %8 = arith.index_cast %7 : i64 to index
          %9 = memref.load %alloca[%8] : memref<64xi32>
          fifo.push(%arg2 : !fifo.input_port<i32>, %9 : i32)
        }
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_1(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i8>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c255_i32 = arith.constant 255 : i32
    %c128_i32 = arith.constant 128 : i32
    %c13_i32 = arith.constant 13 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "shift" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = memref.load %alloca[%arg3] : memref<64xi32>
        %3 = arith.shrsi %2, %c13_i32 : i32
        %4 = arith.addi %3, %c128_i32 : i32
        %5 = arith.cmpi sgt, %4, %c255_i32 : i32
        %6 = scf.if %5 -> (i32) {
          scf.yield %c255_i32 : i32
        } else {
          %8 = arith.cmpi slt, %4, %c0_i32 : i32
          %9 = arith.select %8, %c0_i32, %4 : i32
          scf.yield %9 : i32
        }
        %7 = arith.trunci %6 : i32 to i8
        fifo.push(%arg2 : !fifo.input_port<i8>, %7 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_2(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i13>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c4096_i32 = arith.constant 4096 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c2528_i32 = arith.constant 2528 : i32
    %c2718_i32 = arith.constant 2718 : i32
    %c2923_i32 = arith.constant 2923 : i32
    %c1788_i32 = arith.constant 1788 : i32
    %c1922_i32 = arith.constant 1922 : i32
    %c1264_i32 = arith.constant 1264 : i32
    %c1609_i32 = arith.constant 1609 : i32
    %c1730_i32 = arith.constant 1730 : i32
    %c1138_i32 = arith.constant 1138 : i32
    %c1024_i32 = arith.constant 1024 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c1024_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c1138_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c1730_i32 : i32)
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c1609_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c1264_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c1922_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c1788_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c2923_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c2718_i32 : i32)
    %10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%10 : !cal.state_ref<i32>, %c2528_i32 : i32)
    %11 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %12 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %13 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %13, %12 : memref<64xi16> to memref<64xi16>
    %14 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%14 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "scale" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi13>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = fifo.pop(%arg1 : !fifo.output_port<i13>) : i13
        memref.store %19, %alloca_0[%arg3] : memref<64xi13>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca_0[%arg3] : memref<64xi13>
        %20 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %21 = memref.load %20[%arg3] : memref<64xi16>
        %22 = arith.extsi %19 : i13 to i32
        %23 = arith.extsi %21 : i16 to i32
        %24 = arith.muli %22, %23 : i32
        memref.store %24, %alloca[%arg3] : memref<64xi32>
      }
      %15 = memref.load %alloca[%c0] : memref<64xi32>
      %16 = arith.addi %15, %c4096_i32 : i32
      memref.store %16, %alloca[%c0] : memref<64xi32>
      %17 = cal.get(%14 : !cal.state_ref<i64>) : i64
      %18 = arith.addi %17, %c64_i64 : i64
      cal.set(%14 : !cal.state_ref<i64>, %18 : i64)
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca[%arg3] : memref<64xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %19 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_2(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c4_i32 = arith.constant 4 : i32
    %c2_i32 = arith.constant 2 : i32
    %c9_i32 = arith.constant 9 : i32
    %c11_i32 = arith.constant 11 : i32
    %c5_i32 = arith.constant 5 : i32
    %c3_i32 = arith.constant 3 : i32
    %c7_i32 = arith.constant 7 : i32
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<8xi32>
      %alloca_0 = memref.alloca() : memref<8xi32>
      %alloca_1 = memref.alloca() : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %100, %alloca_1[%arg3] : memref<8xi32>
      }
      memref.copy %alloca_1, %alloca_0 : memref<8xi32> to memref<8xi32>
      %2 = memref.load %alloca_0[%c1] : memref<8xi32>
      %3 = memref.load %alloca_0[%c7] : memref<8xi32>
      %4 = arith.addi %2, %3 : i32
      %5 = arith.subi %2, %3 : i32
      %6 = memref.load %alloca_0[%c3] : memref<8xi32>
      %7 = arith.addi %4, %6 : i32
      memref.store %7, %alloca_0[%c1] : memref<8xi32>
      %8 = memref.load %alloca_0[%c3] : memref<8xi32>
      %9 = arith.subi %4, %8 : i32
      memref.store %9, %alloca_0[%c3] : memref<8xi32>
      %10 = memref.load %alloca_0[%c5] : memref<8xi32>
      %11 = arith.addi %5, %10 : i32
      memref.store %11, %alloca_0[%c7] : memref<8xi32>
      %12 = memref.load %alloca_0[%c5] : memref<8xi32>
      %13 = arith.subi %5, %12 : i32
      memref.store %13, %alloca_0[%c5] : memref<8xi32>
      %14 = memref.load %alloca_0[%c3] : memref<8xi32>
      %15 = arith.shrsi %14, %c3_i32 : i32
      %16 = arith.shrsi %14, %c7_i32 : i32
      %17 = arith.subi %15, %16 : i32
      %18 = arith.subi %14, %17 : i32
      %19 = arith.shrsi %14, %c11_i32 : i32
      %20 = arith.subi %17, %19 : i32
      %21 = arith.shrsi %20, %c1_i32 : i32
      %22 = arith.addi %17, %21 : i32
      %23 = memref.load %alloca_0[%c5] : memref<8xi32>
      %24 = arith.shrsi %23, %c3_i32 : i32
      %25 = arith.shrsi %23, %c7_i32 : i32
      %26 = arith.subi %24, %25 : i32
      %27 = arith.subi %23, %26 : i32
      %28 = arith.shrsi %23, %c11_i32 : i32
      %29 = arith.subi %26, %28 : i32
      %30 = arith.shrsi %29, %c1_i32 : i32
      %31 = arith.addi %26, %30 : i32
      %32 = arith.subi %18, %31 : i32
      memref.store %32, %alloca_0[%c3] : memref<8xi32>
      %33 = arith.addi %27, %22 : i32
      memref.store %33, %alloca_0[%c5] : memref<8xi32>
      %34 = memref.load %alloca_0[%c1] : memref<8xi32>
      %35 = arith.shrsi %34, %c9_i32 : i32
      %36 = arith.subi %35, %34 : i32
      %37 = arith.shrsi %36, %c2_i32 : i32
      %38 = arith.subi %37, %36 : i32
      %39 = arith.shrsi %34, %c1_i32 : i32
      %40 = memref.load %alloca_0[%c7] : memref<8xi32>
      %41 = arith.shrsi %40, %c9_i32 : i32
      %42 = arith.subi %41, %40 : i32
      %43 = arith.shrsi %42, %c2_i32 : i32
      %44 = arith.subi %43, %42 : i32
      %45 = arith.shrsi %40, %c1_i32 : i32
      %46 = arith.addi %38, %45 : i32
      memref.store %46, %alloca_0[%c1] : memref<8xi32>
      %47 = arith.subi %44, %39 : i32
      memref.store %47, %alloca_0[%c7] : memref<8xi32>
      %48 = memref.load %alloca_0[%c2] : memref<8xi32>
      %49 = arith.shrsi %48, %c5_i32 : i32
      %50 = arith.addi %48, %49 : i32
      %51 = arith.shrsi %50, %c2_i32 : i32
      %52 = arith.shrsi %48, %c4_i32 : i32
      %53 = arith.addi %51, %52 : i32
      %54 = arith.subi %50, %51 : i32
      %55 = memref.load %alloca_0[%c6] : memref<8xi32>
      %56 = arith.shrsi %55, %c5_i32 : i32
      %57 = arith.addi %55, %56 : i32
      %58 = arith.shrsi %57, %c2_i32 : i32
      %59 = arith.shrsi %55, %c4_i32 : i32
      %60 = arith.addi %58, %59 : i32
      %61 = arith.subi %57, %58 : i32
      %62 = arith.subi %53, %61 : i32
      memref.store %62, %alloca_0[%c2] : memref<8xi32>
      %63 = arith.addi %60, %54 : i32
      memref.store %63, %alloca_0[%c6] : memref<8xi32>
      %64 = memref.load %alloca_0[%c0] : memref<8xi32>
      %65 = memref.load %alloca_0[%c4] : memref<8xi32>
      %66 = arith.addi %64, %65 : i32
      %67 = arith.subi %64, %65 : i32
      %68 = memref.load %alloca_0[%c6] : memref<8xi32>
      %69 = arith.addi %66, %68 : i32
      memref.store %69, %alloca_0[%c0] : memref<8xi32>
      %70 = memref.load %alloca_0[%c6] : memref<8xi32>
      %71 = arith.subi %66, %70 : i32
      memref.store %71, %alloca_0[%c6] : memref<8xi32>
      %72 = memref.load %alloca_0[%c2] : memref<8xi32>
      %73 = arith.addi %67, %72 : i32
      memref.store %73, %alloca_0[%c4] : memref<8xi32>
      %74 = memref.load %alloca_0[%c2] : memref<8xi32>
      %75 = arith.subi %67, %74 : i32
      memref.store %75, %alloca_0[%c2] : memref<8xi32>
      %76 = memref.load %alloca_0[%c0] : memref<8xi32>
      %77 = memref.load %alloca_0[%c1] : memref<8xi32>
      %78 = arith.addi %76, %77 : i32
      memref.store %78, %alloca[%c0] : memref<8xi32>
      %79 = memref.load %alloca_0[%c4] : memref<8xi32>
      %80 = memref.load %alloca_0[%c5] : memref<8xi32>
      %81 = arith.addi %79, %80 : i32
      memref.store %81, %alloca[%c1] : memref<8xi32>
      %82 = memref.load %alloca_0[%c2] : memref<8xi32>
      %83 = memref.load %alloca_0[%c3] : memref<8xi32>
      %84 = arith.addi %82, %83 : i32
      memref.store %84, %alloca[%c2] : memref<8xi32>
      %85 = memref.load %alloca_0[%c6] : memref<8xi32>
      %86 = memref.load %alloca_0[%c7] : memref<8xi32>
      %87 = arith.addi %85, %86 : i32
      memref.store %87, %alloca[%c3] : memref<8xi32>
      %88 = memref.load %alloca_0[%c6] : memref<8xi32>
      %89 = memref.load %alloca_0[%c7] : memref<8xi32>
      %90 = arith.subi %88, %89 : i32
      memref.store %90, %alloca[%c4] : memref<8xi32>
      %91 = memref.load %alloca_0[%c2] : memref<8xi32>
      %92 = memref.load %alloca_0[%c3] : memref<8xi32>
      %93 = arith.subi %91, %92 : i32
      memref.store %93, %alloca[%c5] : memref<8xi32>
      %94 = memref.load %alloca_0[%c4] : memref<8xi32>
      %95 = memref.load %alloca_0[%c5] : memref<8xi32>
      %96 = arith.subi %94, %95 : i32
      memref.store %96, %alloca[%c6] : memref<8xi32>
      %97 = memref.load %alloca_0[%c0] : memref<8xi32>
      %98 = memref.load %alloca_0[%c1] : memref<8xi32>
      %99 = arith.subi %97, %98 : i32
      memref.store %99, %alloca[%c7] : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = memref.load %alloca[%arg3] : memref<8xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %100 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_2(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c8_i64 = arith.constant 8 : i64
    %c8 = arith.constant 8 : index
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %2 = arith.index_cast %arg3 : index to i32
        scf.for %arg4 = %c0 to %c8 step %c1 {
          %3 = arith.index_cast %arg4 : index to i32
          %4 = arith.extsi %3 : i32 to i64
          %5 = arith.muli %4, %c8_i64 : i64
          %6 = arith.extsi %2 : i32 to i64
          %7 = arith.addi %5, %6 : i64
          %8 = arith.index_cast %7 : i64 to index
          %9 = memref.load %alloca[%8] : memref<64xi32>
          fifo.push(%arg2 : !fifo.input_port<i32>, %9 : i32)
        }
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_2(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i8>
    )
  {
    %c0_i64 = arith.constant 0 : i64
    %c255_i32 = arith.constant 255 : i32
    %c128_i32 = arith.constant 128 : i32
    %c13_i32 = arith.constant 13 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %arg0 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "shift" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = memref.load %alloca[%arg3] : memref<64xi32>
        %3 = arith.shrsi %2, %c13_i32 : i32
        %4 = arith.addi %3, %c128_i32 : i32
        %5 = arith.cmpi sgt, %4, %c255_i32 : i32
        %6 = scf.if %5 -> (i32) {
          scf.yield %c255_i32 : i32
        } else {
          %8 = arith.cmpi slt, %4, %c0_i32 : i32
          %9 = arith.select %8, %c0_i32, %4 : i32
          scf.yield %9 : i32
        }
        %7 = arith.trunci %6 : i32 to i8
        fifo.push(%arg2 : !fifo.input_port<i8>, %7 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_dequant__Dequant__v__mb_1$spec_6088779056661456774(%arg0: i32)
    in_names ["SOI", "QT", "Block"]
    out_names ["Out"]
    ports_in (
      %arg1: !fifo.output_port<i16>, 
      %arg2: !fifo.output_port<i8>, 
      %arg3: !fifo.output_port<i24>
    )
    ports_out (
      %arg4: !fifo.input_port<i13>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<memref<64xi6>> : !cal.state_ref<memref<64xi6>>
    %1 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
    %2 = memref.get_global @__cmr_4 : memref<64xi6>
    memref.copy %2, %1 : memref<64xi6> to memref<64xi6>
    %3 = cal.create_state_var<memref<64xi8>> : !cal.state_ref<memref<64xi8>>
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c0_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.fsm {
      cal.state @s0 {
        cal.transition action("get_SOI") -> @s1
      } {initial}
      cal.state @s1 {
        cal.transition action("receive_QT") -> @s2
      }
      cal.state @s2 {
        cal.transition action("receive_block") -> @s2
        cal.transition action("eoi") -> @s0
      }
    }
    cal.action "get_SOI" priority=3
    {
      %6 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %7 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %8 = arith.extui %6 : i16 to i64
      %9 = arith.extui %7 : i16 to i64
      %10 = arith.muli %8, %9 : i64
      %11 = arith.trunci %10 : i64 to i32
      cal.set(%4 : !cal.state_ref<i32>, %11 : i32)
      cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    }
    
    cal.action "receive_QT" priority=3
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = fifo.pop(%arg2 : !fifo.output_port<i8>) : i8
        memref.store %7, %alloca[%arg5] : memref<64xi8>
      }
      %6 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = memref.load %alloca[%arg5] : memref<64xi8>
        memref.store %7, %6[%arg5] : memref<64xi8>
      }
    }
    
    cal.action "receive_block" priority=2
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi24>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = fifo.pop(%arg3 : !fifo.output_port<i24>) : i24
        memref.store %8, %alloca_0[%arg5] : memref<64xi24>
      }
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = memref.load %alloca_0[%arg5] : memref<64xi24>
        %9 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
        %10 = memref.load %9[%arg5] : memref<64xi8>
        %11 = arith.extsi %8 : i24 to i48
        %12 = arith.extsi %10 : i8 to i48
        %13 = arith.muli %11, %12 : i48
        %14 = arith.trunci %13 : i48 to i32
        memref.store %14, %alloca[%arg5] : memref<64xi32>
      }
      %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %7 = arith.addi %6, %c1_i32 : i32
      cal.set(%5 : !cal.state_ref<i32>, %7 : i32)
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
        %9 = memref.load %8[%arg5] : memref<64xi6>
        %10 = arith.extui %9 : i6 to i32
        %11 = arith.index_cast %10 : i32 to index
        %12 = memref.load %alloca[%11] : memref<64xi32>
        %13 = arith.trunci %12 : i32 to i13
        fifo.push(%arg4 : !fifo.input_port<i13>, %13 : i13)
      }
    }
    
    cal.action "eoi" priority=3
    {
      cal.predicate {
        %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
        %7 = cal.get(%4 : !cal.state_ref<i32>) : i32
        %8 = arith.cmpi eq, %6, %7 : i32
        cal.predicate_result %8 : i1
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_dequant__Dequant__v__mb_4$spec_3615608688897599026(%arg0: i32)
    in_names ["SOI", "QT", "Block"]
    out_names ["Out"]
    ports_in (
      %arg1: !fifo.output_port<i16>, 
      %arg2: !fifo.output_port<i8>, 
      %arg3: !fifo.output_port<i24>
    )
    ports_out (
      %arg4: !fifo.input_port<i13>
    )
  {
    %c4_i64 = arith.constant 4 : i64
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<memref<64xi6>> : !cal.state_ref<memref<64xi6>>
    %1 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
    %2 = memref.get_global @__cmr_4 : memref<64xi6>
    memref.copy %2, %1 : memref<64xi6> to memref<64xi6>
    %3 = cal.create_state_var<memref<64xi8>> : !cal.state_ref<memref<64xi8>>
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c0_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.fsm {
      cal.state @s0 {
        cal.transition action("get_SOI") -> @s1
      } {initial}
      cal.state @s1 {
        cal.transition action("receive_QT") -> @s2
      }
      cal.state @s2 {
        cal.transition action("receive_block") -> @s2
        cal.transition action("eoi") -> @s0
      }
    }
    cal.action "get_SOI" priority=3
    {
      %6 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %7 = fifo.pop(%arg1 : !fifo.output_port<i16>) : i16
      %8 = arith.extui %6 : i16 to i64
      %9 = arith.muli %8, %c4_i64 : i64
      %10 = arith.extui %7 : i16 to i64
      %11 = arith.muli %9, %10 : i64
      %12 = arith.trunci %11 : i64 to i32
      cal.set(%4 : !cal.state_ref<i32>, %12 : i32)
      cal.set(%5 : !cal.state_ref<i32>, %c0_i32 : i32)
    }
    
    cal.action "receive_QT" priority=3
    {
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = fifo.pop(%arg2 : !fifo.output_port<i8>) : i8
        memref.store %7, %alloca[%arg5] : memref<64xi8>
      }
      %6 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %7 = memref.load %alloca[%arg5] : memref<64xi8>
        memref.store %7, %6[%arg5] : memref<64xi8>
      }
    }
    
    cal.action "receive_block" priority=2
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi24>
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = fifo.pop(%arg3 : !fifo.output_port<i24>) : i24
        memref.store %8, %alloca_0[%arg5] : memref<64xi24>
      }
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = memref.load %alloca_0[%arg5] : memref<64xi24>
        %9 = cal.get(%3 : !cal.state_ref<memref<64xi8>>) : memref<64xi8>
        %10 = memref.load %9[%arg5] : memref<64xi8>
        %11 = arith.extsi %8 : i24 to i48
        %12 = arith.extsi %10 : i8 to i48
        %13 = arith.muli %11, %12 : i48
        %14 = arith.trunci %13 : i48 to i32
        memref.store %14, %alloca[%arg5] : memref<64xi32>
      }
      %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
      %7 = arith.addi %6, %c1_i32 : i32
      cal.set(%5 : !cal.state_ref<i32>, %7 : i32)
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %8 = cal.get(%0 : !cal.state_ref<memref<64xi6>>) : memref<64xi6>
        %9 = memref.load %8[%arg5] : memref<64xi6>
        %10 = arith.extui %9 : i6 to i32
        %11 = arith.index_cast %10 : i32 to index
        %12 = memref.load %alloca[%11] : memref<64xi32>
        %13 = arith.trunci %12 : i32 to i13
        fifo.push(%arg4 : !fifo.input_port<i13>, %13 : i13)
      }
    }
    
    cal.action "eoi" priority=3
    {
      cal.predicate {
        %6 = cal.get(%5 : !cal.state_ref<i32>) : i32
        %7 = cal.get(%4 : !cal.state_ref<i32>) : i32
        %8 = arith.cmpi eq, %6, %7 : i32
        cal.predicate_result %8 : i1
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_0$spec_12006719495379002532(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i8>
    )
  {
    %c2_i32 = arith.constant 2 : i32
    %c0_i64 = arith.constant 0 : i64
    %c255_i32 = arith.constant 255 : i32
    %c128_i32 = arith.constant 128 : i32
    %c13_i32 = arith.constant 13 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c2_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "shift" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = memref.load %alloca[%arg3] : memref<64xi32>
        %3 = arith.shrsi %2, %c13_i32 : i32
        %4 = arith.addi %3, %c128_i32 : i32
        %5 = arith.cmpi sgt, %4, %c255_i32 : i32
        %6 = scf.if %5 -> (i32) {
          scf.yield %c255_i32 : i32
        } else {
          %8 = arith.cmpi slt, %4, %c0_i32 : i32
          %9 = arith.select %8, %c0_i32, %4 : i32
          scf.yield %9 : i32
        }
        %7 = arith.trunci %6 : i32 to i8
        fifo.push(%arg2 : !fifo.input_port<i8>, %7 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_16004628908213936899(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c2_i32 = arith.constant 2 : i32
    %c8_i64 = arith.constant 8 : i64
    %c8 = arith.constant 8 : index
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c2_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %2 = arith.index_cast %arg3 : index to i32
        scf.for %arg4 = %c0 to %c8 step %c1 {
          %3 = arith.index_cast %arg4 : index to i32
          %4 = arith.extsi %3 : i32 to i64
          %5 = arith.muli %4, %c8_i64 : i64
          %6 = arith.extsi %2 : i32 to i64
          %7 = arith.addi %5, %6 : i64
          %8 = arith.index_cast %7 : i64 to index
          %9 = memref.load %alloca[%8] : memref<64xi32>
          fifo.push(%arg2 : !fifo.input_port<i32>, %9 : i32)
        }
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_13175051422739902479(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c2_i32 = arith.constant 2 : i32
    %c0_i64 = arith.constant 0 : i64
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c4_i32 = arith.constant 4 : i32
    %c9_i32 = arith.constant 9 : i32
    %c11_i32 = arith.constant 11 : i32
    %c5_i32 = arith.constant 5 : i32
    %c3_i32 = arith.constant 3 : i32
    %c7_i32 = arith.constant 7 : i32
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c2_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<8xi32>
      %alloca_0 = memref.alloca() : memref<8xi32>
      %alloca_1 = memref.alloca() : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %100, %alloca_1[%arg3] : memref<8xi32>
      }
      memref.copy %alloca_1, %alloca_0 : memref<8xi32> to memref<8xi32>
      %2 = memref.load %alloca_0[%c1] : memref<8xi32>
      %3 = memref.load %alloca_0[%c7] : memref<8xi32>
      %4 = arith.addi %2, %3 : i32
      %5 = arith.subi %2, %3 : i32
      %6 = memref.load %alloca_0[%c3] : memref<8xi32>
      %7 = arith.addi %4, %6 : i32
      memref.store %7, %alloca_0[%c1] : memref<8xi32>
      %8 = memref.load %alloca_0[%c3] : memref<8xi32>
      %9 = arith.subi %4, %8 : i32
      memref.store %9, %alloca_0[%c3] : memref<8xi32>
      %10 = memref.load %alloca_0[%c5] : memref<8xi32>
      %11 = arith.addi %5, %10 : i32
      memref.store %11, %alloca_0[%c7] : memref<8xi32>
      %12 = memref.load %alloca_0[%c5] : memref<8xi32>
      %13 = arith.subi %5, %12 : i32
      memref.store %13, %alloca_0[%c5] : memref<8xi32>
      %14 = memref.load %alloca_0[%c3] : memref<8xi32>
      %15 = arith.shrsi %14, %c3_i32 : i32
      %16 = arith.shrsi %14, %c7_i32 : i32
      %17 = arith.subi %15, %16 : i32
      %18 = arith.subi %14, %17 : i32
      %19 = arith.shrsi %14, %c11_i32 : i32
      %20 = arith.subi %17, %19 : i32
      %21 = arith.shrsi %20, %c1_i32 : i32
      %22 = arith.addi %17, %21 : i32
      %23 = memref.load %alloca_0[%c5] : memref<8xi32>
      %24 = arith.shrsi %23, %c3_i32 : i32
      %25 = arith.shrsi %23, %c7_i32 : i32
      %26 = arith.subi %24, %25 : i32
      %27 = arith.subi %23, %26 : i32
      %28 = arith.shrsi %23, %c11_i32 : i32
      %29 = arith.subi %26, %28 : i32
      %30 = arith.shrsi %29, %c1_i32 : i32
      %31 = arith.addi %26, %30 : i32
      %32 = arith.subi %18, %31 : i32
      memref.store %32, %alloca_0[%c3] : memref<8xi32>
      %33 = arith.addi %27, %22 : i32
      memref.store %33, %alloca_0[%c5] : memref<8xi32>
      %34 = memref.load %alloca_0[%c1] : memref<8xi32>
      %35 = arith.shrsi %34, %c9_i32 : i32
      %36 = arith.subi %35, %34 : i32
      %37 = arith.shrsi %36, %c2_i32 : i32
      %38 = arith.subi %37, %36 : i32
      %39 = arith.shrsi %34, %c1_i32 : i32
      %40 = memref.load %alloca_0[%c7] : memref<8xi32>
      %41 = arith.shrsi %40, %c9_i32 : i32
      %42 = arith.subi %41, %40 : i32
      %43 = arith.shrsi %42, %c2_i32 : i32
      %44 = arith.subi %43, %42 : i32
      %45 = arith.shrsi %40, %c1_i32 : i32
      %46 = arith.addi %38, %45 : i32
      memref.store %46, %alloca_0[%c1] : memref<8xi32>
      %47 = arith.subi %44, %39 : i32
      memref.store %47, %alloca_0[%c7] : memref<8xi32>
      %48 = memref.load %alloca_0[%c2] : memref<8xi32>
      %49 = arith.shrsi %48, %c5_i32 : i32
      %50 = arith.addi %48, %49 : i32
      %51 = arith.shrsi %50, %c2_i32 : i32
      %52 = arith.shrsi %48, %c4_i32 : i32
      %53 = arith.addi %51, %52 : i32
      %54 = arith.subi %50, %51 : i32
      %55 = memref.load %alloca_0[%c6] : memref<8xi32>
      %56 = arith.shrsi %55, %c5_i32 : i32
      %57 = arith.addi %55, %56 : i32
      %58 = arith.shrsi %57, %c2_i32 : i32
      %59 = arith.shrsi %55, %c4_i32 : i32
      %60 = arith.addi %58, %59 : i32
      %61 = arith.subi %57, %58 : i32
      %62 = arith.subi %53, %61 : i32
      memref.store %62, %alloca_0[%c2] : memref<8xi32>
      %63 = arith.addi %60, %54 : i32
      memref.store %63, %alloca_0[%c6] : memref<8xi32>
      %64 = memref.load %alloca_0[%c0] : memref<8xi32>
      %65 = memref.load %alloca_0[%c4] : memref<8xi32>
      %66 = arith.addi %64, %65 : i32
      %67 = arith.subi %64, %65 : i32
      %68 = memref.load %alloca_0[%c6] : memref<8xi32>
      %69 = arith.addi %66, %68 : i32
      memref.store %69, %alloca_0[%c0] : memref<8xi32>
      %70 = memref.load %alloca_0[%c6] : memref<8xi32>
      %71 = arith.subi %66, %70 : i32
      memref.store %71, %alloca_0[%c6] : memref<8xi32>
      %72 = memref.load %alloca_0[%c2] : memref<8xi32>
      %73 = arith.addi %67, %72 : i32
      memref.store %73, %alloca_0[%c4] : memref<8xi32>
      %74 = memref.load %alloca_0[%c2] : memref<8xi32>
      %75 = arith.subi %67, %74 : i32
      memref.store %75, %alloca_0[%c2] : memref<8xi32>
      %76 = memref.load %alloca_0[%c0] : memref<8xi32>
      %77 = memref.load %alloca_0[%c1] : memref<8xi32>
      %78 = arith.addi %76, %77 : i32
      memref.store %78, %alloca[%c0] : memref<8xi32>
      %79 = memref.load %alloca_0[%c4] : memref<8xi32>
      %80 = memref.load %alloca_0[%c5] : memref<8xi32>
      %81 = arith.addi %79, %80 : i32
      memref.store %81, %alloca[%c1] : memref<8xi32>
      %82 = memref.load %alloca_0[%c2] : memref<8xi32>
      %83 = memref.load %alloca_0[%c3] : memref<8xi32>
      %84 = arith.addi %82, %83 : i32
      memref.store %84, %alloca[%c2] : memref<8xi32>
      %85 = memref.load %alloca_0[%c6] : memref<8xi32>
      %86 = memref.load %alloca_0[%c7] : memref<8xi32>
      %87 = arith.addi %85, %86 : i32
      memref.store %87, %alloca[%c3] : memref<8xi32>
      %88 = memref.load %alloca_0[%c6] : memref<8xi32>
      %89 = memref.load %alloca_0[%c7] : memref<8xi32>
      %90 = arith.subi %88, %89 : i32
      memref.store %90, %alloca[%c4] : memref<8xi32>
      %91 = memref.load %alloca_0[%c2] : memref<8xi32>
      %92 = memref.load %alloca_0[%c3] : memref<8xi32>
      %93 = arith.subi %91, %92 : i32
      memref.store %93, %alloca[%c5] : memref<8xi32>
      %94 = memref.load %alloca_0[%c4] : memref<8xi32>
      %95 = memref.load %alloca_0[%c5] : memref<8xi32>
      %96 = arith.subi %94, %95 : i32
      memref.store %96, %alloca[%c6] : memref<8xi32>
      %97 = memref.load %alloca_0[%c0] : memref<8xi32>
      %98 = memref.load %alloca_0[%c1] : memref<8xi32>
      %99 = arith.subi %97, %98 : i32
      memref.store %99, %alloca[%c7] : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = memref.load %alloca[%arg3] : memref<8xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %100 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_0$spec_5973899596462999001(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i13>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c2_i32 = arith.constant 2 : i32
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c4096_i32 = arith.constant 4096 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c2528_i32 = arith.constant 2528 : i32
    %c2718_i32 = arith.constant 2718 : i32
    %c2923_i32 = arith.constant 2923 : i32
    %c1788_i32 = arith.constant 1788 : i32
    %c1922_i32 = arith.constant 1922 : i32
    %c1264_i32 = arith.constant 1264 : i32
    %c1609_i32 = arith.constant 1609 : i32
    %c1730_i32 = arith.constant 1730 : i32
    %c1138_i32 = arith.constant 1138 : i32
    %c1024_i32 = arith.constant 1024 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c2_i32 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c1024_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c1138_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c1730_i32 : i32)
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c1609_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c1264_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c1922_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c1788_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c2923_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c2718_i32 : i32)
    %10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%10 : !cal.state_ref<i32>, %c2528_i32 : i32)
    %11 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %12 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %13 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %13, %12 : memref<64xi16> to memref<64xi16>
    %14 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%14 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "scale" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi13>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = fifo.pop(%arg1 : !fifo.output_port<i13>) : i13
        memref.store %19, %alloca_0[%arg3] : memref<64xi13>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca_0[%arg3] : memref<64xi13>
        %20 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %21 = memref.load %20[%arg3] : memref<64xi16>
        %22 = arith.extsi %19 : i13 to i32
        %23 = arith.extsi %21 : i16 to i32
        %24 = arith.muli %22, %23 : i32
        memref.store %24, %alloca[%arg3] : memref<64xi32>
      }
      %15 = memref.load %alloca[%c0] : memref<64xi32>
      %16 = arith.addi %15, %c4096_i32 : i32
      memref.store %16, %alloca[%c0] : memref<64xi32>
      %17 = cal.get(%14 : !cal.state_ref<i64>) : i64
      %18 = arith.addi %17, %c64_i64 : i64
      cal.set(%14 : !cal.state_ref<i64>, %18 : i64)
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca[%arg3] : memref<64xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %19 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_0$spec_14167312006875771836(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i8>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c0_i64 = arith.constant 0 : i64
    %c255_i32 = arith.constant 255 : i32
    %c128_i32 = arith.constant 128 : i32
    %c13_i32 = arith.constant 13 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c1_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "shift" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = memref.load %alloca[%arg3] : memref<64xi32>
        %3 = arith.shrsi %2, %c13_i32 : i32
        %4 = arith.addi %3, %c128_i32 : i32
        %5 = arith.cmpi sgt, %4, %c255_i32 : i32
        %6 = scf.if %5 -> (i32) {
          scf.yield %c255_i32 : i32
        } else {
          %8 = arith.cmpi slt, %4, %c0_i32 : i32
          %9 = arith.select %8, %c0_i32, %4 : i32
          scf.yield %9 : i32
        }
        %7 = arith.trunci %6 : i32 to i8
        fifo.push(%arg2 : !fifo.input_port<i8>, %7 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_7626260950822058466(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c8_i64 = arith.constant 8 : i64
    %c8 = arith.constant 8 : index
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c1_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %2 = arith.index_cast %arg3 : index to i32
        scf.for %arg4 = %c0 to %c8 step %c1 {
          %3 = arith.index_cast %arg4 : index to i32
          %4 = arith.extsi %3 : i32 to i64
          %5 = arith.muli %4, %c8_i64 : i64
          %6 = arith.extsi %2 : i32 to i64
          %7 = arith.addi %5, %6 : i64
          %8 = arith.index_cast %7 : i64 to index
          %9 = memref.load %alloca[%8] : memref<64xi32>
          fifo.push(%arg2 : !fifo.input_port<i32>, %9 : i32)
        }
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_8975415057449214135(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c0_i64 = arith.constant 0 : i64
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c4_i32 = arith.constant 4 : i32
    %c2_i32 = arith.constant 2 : i32
    %c9_i32 = arith.constant 9 : i32
    %c11_i32 = arith.constant 11 : i32
    %c5_i32 = arith.constant 5 : i32
    %c3_i32 = arith.constant 3 : i32
    %c7_i32 = arith.constant 7 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c1_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<8xi32>
      %alloca_0 = memref.alloca() : memref<8xi32>
      %alloca_1 = memref.alloca() : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %100, %alloca_1[%arg3] : memref<8xi32>
      }
      memref.copy %alloca_1, %alloca_0 : memref<8xi32> to memref<8xi32>
      %2 = memref.load %alloca_0[%c1] : memref<8xi32>
      %3 = memref.load %alloca_0[%c7] : memref<8xi32>
      %4 = arith.addi %2, %3 : i32
      %5 = arith.subi %2, %3 : i32
      %6 = memref.load %alloca_0[%c3] : memref<8xi32>
      %7 = arith.addi %4, %6 : i32
      memref.store %7, %alloca_0[%c1] : memref<8xi32>
      %8 = memref.load %alloca_0[%c3] : memref<8xi32>
      %9 = arith.subi %4, %8 : i32
      memref.store %9, %alloca_0[%c3] : memref<8xi32>
      %10 = memref.load %alloca_0[%c5] : memref<8xi32>
      %11 = arith.addi %5, %10 : i32
      memref.store %11, %alloca_0[%c7] : memref<8xi32>
      %12 = memref.load %alloca_0[%c5] : memref<8xi32>
      %13 = arith.subi %5, %12 : i32
      memref.store %13, %alloca_0[%c5] : memref<8xi32>
      %14 = memref.load %alloca_0[%c3] : memref<8xi32>
      %15 = arith.shrsi %14, %c3_i32 : i32
      %16 = arith.shrsi %14, %c7_i32 : i32
      %17 = arith.subi %15, %16 : i32
      %18 = arith.subi %14, %17 : i32
      %19 = arith.shrsi %14, %c11_i32 : i32
      %20 = arith.subi %17, %19 : i32
      %21 = arith.shrsi %20, %c1_i32 : i32
      %22 = arith.addi %17, %21 : i32
      %23 = memref.load %alloca_0[%c5] : memref<8xi32>
      %24 = arith.shrsi %23, %c3_i32 : i32
      %25 = arith.shrsi %23, %c7_i32 : i32
      %26 = arith.subi %24, %25 : i32
      %27 = arith.subi %23, %26 : i32
      %28 = arith.shrsi %23, %c11_i32 : i32
      %29 = arith.subi %26, %28 : i32
      %30 = arith.shrsi %29, %c1_i32 : i32
      %31 = arith.addi %26, %30 : i32
      %32 = arith.subi %18, %31 : i32
      memref.store %32, %alloca_0[%c3] : memref<8xi32>
      %33 = arith.addi %27, %22 : i32
      memref.store %33, %alloca_0[%c5] : memref<8xi32>
      %34 = memref.load %alloca_0[%c1] : memref<8xi32>
      %35 = arith.shrsi %34, %c9_i32 : i32
      %36 = arith.subi %35, %34 : i32
      %37 = arith.shrsi %36, %c2_i32 : i32
      %38 = arith.subi %37, %36 : i32
      %39 = arith.shrsi %34, %c1_i32 : i32
      %40 = memref.load %alloca_0[%c7] : memref<8xi32>
      %41 = arith.shrsi %40, %c9_i32 : i32
      %42 = arith.subi %41, %40 : i32
      %43 = arith.shrsi %42, %c2_i32 : i32
      %44 = arith.subi %43, %42 : i32
      %45 = arith.shrsi %40, %c1_i32 : i32
      %46 = arith.addi %38, %45 : i32
      memref.store %46, %alloca_0[%c1] : memref<8xi32>
      %47 = arith.subi %44, %39 : i32
      memref.store %47, %alloca_0[%c7] : memref<8xi32>
      %48 = memref.load %alloca_0[%c2] : memref<8xi32>
      %49 = arith.shrsi %48, %c5_i32 : i32
      %50 = arith.addi %48, %49 : i32
      %51 = arith.shrsi %50, %c2_i32 : i32
      %52 = arith.shrsi %48, %c4_i32 : i32
      %53 = arith.addi %51, %52 : i32
      %54 = arith.subi %50, %51 : i32
      %55 = memref.load %alloca_0[%c6] : memref<8xi32>
      %56 = arith.shrsi %55, %c5_i32 : i32
      %57 = arith.addi %55, %56 : i32
      %58 = arith.shrsi %57, %c2_i32 : i32
      %59 = arith.shrsi %55, %c4_i32 : i32
      %60 = arith.addi %58, %59 : i32
      %61 = arith.subi %57, %58 : i32
      %62 = arith.subi %53, %61 : i32
      memref.store %62, %alloca_0[%c2] : memref<8xi32>
      %63 = arith.addi %60, %54 : i32
      memref.store %63, %alloca_0[%c6] : memref<8xi32>
      %64 = memref.load %alloca_0[%c0] : memref<8xi32>
      %65 = memref.load %alloca_0[%c4] : memref<8xi32>
      %66 = arith.addi %64, %65 : i32
      %67 = arith.subi %64, %65 : i32
      %68 = memref.load %alloca_0[%c6] : memref<8xi32>
      %69 = arith.addi %66, %68 : i32
      memref.store %69, %alloca_0[%c0] : memref<8xi32>
      %70 = memref.load %alloca_0[%c6] : memref<8xi32>
      %71 = arith.subi %66, %70 : i32
      memref.store %71, %alloca_0[%c6] : memref<8xi32>
      %72 = memref.load %alloca_0[%c2] : memref<8xi32>
      %73 = arith.addi %67, %72 : i32
      memref.store %73, %alloca_0[%c4] : memref<8xi32>
      %74 = memref.load %alloca_0[%c2] : memref<8xi32>
      %75 = arith.subi %67, %74 : i32
      memref.store %75, %alloca_0[%c2] : memref<8xi32>
      %76 = memref.load %alloca_0[%c0] : memref<8xi32>
      %77 = memref.load %alloca_0[%c1] : memref<8xi32>
      %78 = arith.addi %76, %77 : i32
      memref.store %78, %alloca[%c0] : memref<8xi32>
      %79 = memref.load %alloca_0[%c4] : memref<8xi32>
      %80 = memref.load %alloca_0[%c5] : memref<8xi32>
      %81 = arith.addi %79, %80 : i32
      memref.store %81, %alloca[%c1] : memref<8xi32>
      %82 = memref.load %alloca_0[%c2] : memref<8xi32>
      %83 = memref.load %alloca_0[%c3] : memref<8xi32>
      %84 = arith.addi %82, %83 : i32
      memref.store %84, %alloca[%c2] : memref<8xi32>
      %85 = memref.load %alloca_0[%c6] : memref<8xi32>
      %86 = memref.load %alloca_0[%c7] : memref<8xi32>
      %87 = arith.addi %85, %86 : i32
      memref.store %87, %alloca[%c3] : memref<8xi32>
      %88 = memref.load %alloca_0[%c6] : memref<8xi32>
      %89 = memref.load %alloca_0[%c7] : memref<8xi32>
      %90 = arith.subi %88, %89 : i32
      memref.store %90, %alloca[%c4] : memref<8xi32>
      %91 = memref.load %alloca_0[%c2] : memref<8xi32>
      %92 = memref.load %alloca_0[%c3] : memref<8xi32>
      %93 = arith.subi %91, %92 : i32
      memref.store %93, %alloca[%c5] : memref<8xi32>
      %94 = memref.load %alloca_0[%c4] : memref<8xi32>
      %95 = memref.load %alloca_0[%c5] : memref<8xi32>
      %96 = arith.subi %94, %95 : i32
      memref.store %96, %alloca[%c6] : memref<8xi32>
      %97 = memref.load %alloca_0[%c0] : memref<8xi32>
      %98 = memref.load %alloca_0[%c1] : memref<8xi32>
      %99 = arith.subi %97, %98 : i32
      memref.store %99, %alloca[%c7] : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = memref.load %alloca[%arg3] : memref<8xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %100 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_0$spec_13555646153602813362(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i13>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c4096_i32 = arith.constant 4096 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c2528_i32 = arith.constant 2528 : i32
    %c2718_i32 = arith.constant 2718 : i32
    %c2923_i32 = arith.constant 2923 : i32
    %c1788_i32 = arith.constant 1788 : i32
    %c1922_i32 = arith.constant 1922 : i32
    %c1264_i32 = arith.constant 1264 : i32
    %c1609_i32 = arith.constant 1609 : i32
    %c1730_i32 = arith.constant 1730 : i32
    %c1138_i32 = arith.constant 1138 : i32
    %c1024_i32 = arith.constant 1024 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c1_i32 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c1024_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c1138_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c1730_i32 : i32)
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c1609_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c1264_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c1922_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c1788_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c2923_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c2718_i32 : i32)
    %10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%10 : !cal.state_ref<i32>, %c2528_i32 : i32)
    %11 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %12 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %13 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %13, %12 : memref<64xi16> to memref<64xi16>
    %14 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%14 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "scale" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi13>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = fifo.pop(%arg1 : !fifo.output_port<i13>) : i13
        memref.store %19, %alloca_0[%arg3] : memref<64xi13>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca_0[%arg3] : memref<64xi13>
        %20 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %21 = memref.load %20[%arg3] : memref<64xi16>
        %22 = arith.extsi %19 : i13 to i32
        %23 = arith.extsi %21 : i16 to i32
        %24 = arith.muli %22, %23 : i32
        memref.store %24, %alloca[%arg3] : memref<64xi32>
      }
      %15 = memref.load %alloca[%c0] : memref<64xi32>
      %16 = arith.addi %15, %c4096_i32 : i32
      memref.store %16, %alloca[%c0] : memref<64xi32>
      %17 = cal.get(%14 : !cal.state_ref<i64>) : i64
      %18 = arith.addi %17, %c64_i64 : i64
      cal.set(%14 : !cal.state_ref<i64>, %18 : i64)
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca[%arg3] : memref<64xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %19 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_0$spec_6618446700608443612(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i8>
    )
  {
    %c0_i32 = arith.constant 0 : i32
    %c0_i64 = arith.constant 0 : i64
    %c255_i32 = arith.constant 255 : i32
    %c128_i32 = arith.constant 128 : i32
    %c13_i32 = arith.constant 13 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "shift" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = memref.load %alloca[%arg3] : memref<64xi32>
        %3 = arith.shrsi %2, %c13_i32 : i32
        %4 = arith.addi %3, %c128_i32 : i32
        %5 = arith.cmpi sgt, %4, %c255_i32 : i32
        %6 = scf.if %5 -> (i32) {
          scf.yield %c255_i32 : i32
        } else {
          %8 = arith.cmpi slt, %4, %c0_i32 : i32
          %9 = arith.select %8, %c0_i32, %4 : i32
          scf.yield %9 : i32
        }
        %7 = arith.trunci %6 : i32 to i8
        fifo.push(%arg2 : !fifo.input_port<i8>, %7 : i8)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_0$spec_10873624104233167978(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c0_i32 = arith.constant 0 : i32
    %c8_i64 = arith.constant 8 : i64
    %c8 = arith.constant 8 : index
    %c0_i64 = arith.constant 0 : i64
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %2, %alloca[%arg3] : memref<64xi32>
      }
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %2 = arith.index_cast %arg3 : index to i32
        scf.for %arg4 = %c0 to %c8 step %c1 {
          %3 = arith.index_cast %arg4 : index to i32
          %4 = arith.extsi %3 : i32 to i64
          %5 = arith.muli %4, %c8_i64 : i64
          %6 = arith.extsi %2 : i32 to i64
          %7 = arith.addi %5, %6 : i64
          %8 = arith.index_cast %7 : i64 to index
          %9 = memref.load %alloca[%8] : memref<64xi32>
          fifo.push(%arg2 : !fifo.input_port<i32>, %9 : i32)
        }
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0$spec_169524333309396437(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c0_i32 = arith.constant 0 : i32
    %c0_i64 = arith.constant 0 : i64
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c4_i32 = arith.constant 4 : i32
    %c2_i32 = arith.constant 2 : i32
    %c9_i32 = arith.constant 9 : i32
    %c11_i32 = arith.constant 11 : i32
    %c5_i32 = arith.constant 5 : i32
    %c3_i32 = arith.constant 3 : i32
    %c7_i32 = arith.constant 7 : i32
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%1 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "$untagged0" priority=0
    {
      %alloca = memref.alloca() : memref<8xi32>
      %alloca_0 = memref.alloca() : memref<8xi32>
      %alloca_1 = memref.alloca() : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        memref.store %100, %alloca_1[%arg3] : memref<8xi32>
      }
      memref.copy %alloca_1, %alloca_0 : memref<8xi32> to memref<8xi32>
      %2 = memref.load %alloca_0[%c1] : memref<8xi32>
      %3 = memref.load %alloca_0[%c7] : memref<8xi32>
      %4 = arith.addi %2, %3 : i32
      %5 = arith.subi %2, %3 : i32
      %6 = memref.load %alloca_0[%c3] : memref<8xi32>
      %7 = arith.addi %4, %6 : i32
      memref.store %7, %alloca_0[%c1] : memref<8xi32>
      %8 = memref.load %alloca_0[%c3] : memref<8xi32>
      %9 = arith.subi %4, %8 : i32
      memref.store %9, %alloca_0[%c3] : memref<8xi32>
      %10 = memref.load %alloca_0[%c5] : memref<8xi32>
      %11 = arith.addi %5, %10 : i32
      memref.store %11, %alloca_0[%c7] : memref<8xi32>
      %12 = memref.load %alloca_0[%c5] : memref<8xi32>
      %13 = arith.subi %5, %12 : i32
      memref.store %13, %alloca_0[%c5] : memref<8xi32>
      %14 = memref.load %alloca_0[%c3] : memref<8xi32>
      %15 = arith.shrsi %14, %c3_i32 : i32
      %16 = arith.shrsi %14, %c7_i32 : i32
      %17 = arith.subi %15, %16 : i32
      %18 = arith.subi %14, %17 : i32
      %19 = arith.shrsi %14, %c11_i32 : i32
      %20 = arith.subi %17, %19 : i32
      %21 = arith.shrsi %20, %c1_i32 : i32
      %22 = arith.addi %17, %21 : i32
      %23 = memref.load %alloca_0[%c5] : memref<8xi32>
      %24 = arith.shrsi %23, %c3_i32 : i32
      %25 = arith.shrsi %23, %c7_i32 : i32
      %26 = arith.subi %24, %25 : i32
      %27 = arith.subi %23, %26 : i32
      %28 = arith.shrsi %23, %c11_i32 : i32
      %29 = arith.subi %26, %28 : i32
      %30 = arith.shrsi %29, %c1_i32 : i32
      %31 = arith.addi %26, %30 : i32
      %32 = arith.subi %18, %31 : i32
      memref.store %32, %alloca_0[%c3] : memref<8xi32>
      %33 = arith.addi %27, %22 : i32
      memref.store %33, %alloca_0[%c5] : memref<8xi32>
      %34 = memref.load %alloca_0[%c1] : memref<8xi32>
      %35 = arith.shrsi %34, %c9_i32 : i32
      %36 = arith.subi %35, %34 : i32
      %37 = arith.shrsi %36, %c2_i32 : i32
      %38 = arith.subi %37, %36 : i32
      %39 = arith.shrsi %34, %c1_i32 : i32
      %40 = memref.load %alloca_0[%c7] : memref<8xi32>
      %41 = arith.shrsi %40, %c9_i32 : i32
      %42 = arith.subi %41, %40 : i32
      %43 = arith.shrsi %42, %c2_i32 : i32
      %44 = arith.subi %43, %42 : i32
      %45 = arith.shrsi %40, %c1_i32 : i32
      %46 = arith.addi %38, %45 : i32
      memref.store %46, %alloca_0[%c1] : memref<8xi32>
      %47 = arith.subi %44, %39 : i32
      memref.store %47, %alloca_0[%c7] : memref<8xi32>
      %48 = memref.load %alloca_0[%c2] : memref<8xi32>
      %49 = arith.shrsi %48, %c5_i32 : i32
      %50 = arith.addi %48, %49 : i32
      %51 = arith.shrsi %50, %c2_i32 : i32
      %52 = arith.shrsi %48, %c4_i32 : i32
      %53 = arith.addi %51, %52 : i32
      %54 = arith.subi %50, %51 : i32
      %55 = memref.load %alloca_0[%c6] : memref<8xi32>
      %56 = arith.shrsi %55, %c5_i32 : i32
      %57 = arith.addi %55, %56 : i32
      %58 = arith.shrsi %57, %c2_i32 : i32
      %59 = arith.shrsi %55, %c4_i32 : i32
      %60 = arith.addi %58, %59 : i32
      %61 = arith.subi %57, %58 : i32
      %62 = arith.subi %53, %61 : i32
      memref.store %62, %alloca_0[%c2] : memref<8xi32>
      %63 = arith.addi %60, %54 : i32
      memref.store %63, %alloca_0[%c6] : memref<8xi32>
      %64 = memref.load %alloca_0[%c0] : memref<8xi32>
      %65 = memref.load %alloca_0[%c4] : memref<8xi32>
      %66 = arith.addi %64, %65 : i32
      %67 = arith.subi %64, %65 : i32
      %68 = memref.load %alloca_0[%c6] : memref<8xi32>
      %69 = arith.addi %66, %68 : i32
      memref.store %69, %alloca_0[%c0] : memref<8xi32>
      %70 = memref.load %alloca_0[%c6] : memref<8xi32>
      %71 = arith.subi %66, %70 : i32
      memref.store %71, %alloca_0[%c6] : memref<8xi32>
      %72 = memref.load %alloca_0[%c2] : memref<8xi32>
      %73 = arith.addi %67, %72 : i32
      memref.store %73, %alloca_0[%c4] : memref<8xi32>
      %74 = memref.load %alloca_0[%c2] : memref<8xi32>
      %75 = arith.subi %67, %74 : i32
      memref.store %75, %alloca_0[%c2] : memref<8xi32>
      %76 = memref.load %alloca_0[%c0] : memref<8xi32>
      %77 = memref.load %alloca_0[%c1] : memref<8xi32>
      %78 = arith.addi %76, %77 : i32
      memref.store %78, %alloca[%c0] : memref<8xi32>
      %79 = memref.load %alloca_0[%c4] : memref<8xi32>
      %80 = memref.load %alloca_0[%c5] : memref<8xi32>
      %81 = arith.addi %79, %80 : i32
      memref.store %81, %alloca[%c1] : memref<8xi32>
      %82 = memref.load %alloca_0[%c2] : memref<8xi32>
      %83 = memref.load %alloca_0[%c3] : memref<8xi32>
      %84 = arith.addi %82, %83 : i32
      memref.store %84, %alloca[%c2] : memref<8xi32>
      %85 = memref.load %alloca_0[%c6] : memref<8xi32>
      %86 = memref.load %alloca_0[%c7] : memref<8xi32>
      %87 = arith.addi %85, %86 : i32
      memref.store %87, %alloca[%c3] : memref<8xi32>
      %88 = memref.load %alloca_0[%c6] : memref<8xi32>
      %89 = memref.load %alloca_0[%c7] : memref<8xi32>
      %90 = arith.subi %88, %89 : i32
      memref.store %90, %alloca[%c4] : memref<8xi32>
      %91 = memref.load %alloca_0[%c2] : memref<8xi32>
      %92 = memref.load %alloca_0[%c3] : memref<8xi32>
      %93 = arith.subi %91, %92 : i32
      memref.store %93, %alloca[%c5] : memref<8xi32>
      %94 = memref.load %alloca_0[%c4] : memref<8xi32>
      %95 = memref.load %alloca_0[%c5] : memref<8xi32>
      %96 = arith.subi %94, %95 : i32
      memref.store %96, %alloca[%c6] : memref<8xi32>
      %97 = memref.load %alloca_0[%c0] : memref<8xi32>
      %98 = memref.load %alloca_0[%c1] : memref<8xi32>
      %99 = arith.subi %97, %98 : i32
      memref.store %99, %alloca[%c7] : memref<8xi32>
      scf.for %arg3 = %c0 to %c8 step %c1 {
        %100 = memref.load %alloca[%arg3] : memref<8xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %100 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_0$spec_5840956618029034463(%arg0: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in (
      %arg1: !fifo.output_port<i13>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c0_i32 = arith.constant 0 : i32
    %c64_i64 = arith.constant 64 : i64
    %c0_i64 = arith.constant 0 : i64
    %c4096_i32 = arith.constant 4096 : i32
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c2528_i32 = arith.constant 2528 : i32
    %c2718_i32 = arith.constant 2718 : i32
    %c2923_i32 = arith.constant 2923 : i32
    %c1788_i32 = arith.constant 1788 : i32
    %c1922_i32 = arith.constant 1922 : i32
    %c1264_i32 = arith.constant 1264 : i32
    %c1609_i32 = arith.constant 1609 : i32
    %c1730_i32 = arith.constant 1730 : i32
    %c1138_i32 = arith.constant 1138 : i32
    %c1024_i32 = arith.constant 1024 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c1024_i32 : i32)
    %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%2 : !cal.state_ref<i32>, %c1138_i32 : i32)
    %3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%3 : !cal.state_ref<i32>, %c1730_i32 : i32)
    %4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%4 : !cal.state_ref<i32>, %c1609_i32 : i32)
    %5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%5 : !cal.state_ref<i32>, %c1264_i32 : i32)
    %6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%6 : !cal.state_ref<i32>, %c1922_i32 : i32)
    %7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%7 : !cal.state_ref<i32>, %c1788_i32 : i32)
    %8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%8 : !cal.state_ref<i32>, %c2923_i32 : i32)
    %9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%9 : !cal.state_ref<i32>, %c2718_i32 : i32)
    %10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%10 : !cal.state_ref<i32>, %c2528_i32 : i32)
    %11 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %12 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %13 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %13, %12 : memref<64xi16> to memref<64xi16>
    %14 = cal.create_state_var<i64> : !cal.state_ref<i64>
    cal.set(%14 : !cal.state_ref<i64>, %c0_i64 : i64)
    cal.action "scale" priority=0
    {
      %alloca = memref.alloca() : memref<64xi32>
      %alloca_0 = memref.alloca() : memref<64xi13>
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = fifo.pop(%arg1 : !fifo.output_port<i13>) : i13
        memref.store %19, %alloca_0[%arg3] : memref<64xi13>
      }
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca_0[%arg3] : memref<64xi13>
        %20 = cal.get(%11 : !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %21 = memref.load %20[%arg3] : memref<64xi16>
        %22 = arith.extsi %19 : i13 to i32
        %23 = arith.extsi %21 : i16 to i32
        %24 = arith.muli %22, %23 : i32
        memref.store %24, %alloca[%arg3] : memref<64xi32>
      }
      %15 = memref.load %alloca[%c0] : memref<64xi32>
      %16 = arith.addi %15, %c4096_i32 : i32
      memref.store %16, %alloca[%c0] : memref<64xi32>
      %17 = cal.get(%14 : !cal.state_ref<i64>) : i64
      %18 = arith.addi %17, %c64_i64 : i64
      cal.set(%14 : !cal.state_ref<i64>, %18 : i64)
      scf.for %arg3 = %c0 to %c64 step %c1 {
        %19 = memref.load %alloca[%arg3] : memref<64xi32>
        fifo.push(%arg2 : !fifo.input_port<i32>, %19 : i32)
      }
    }
    
  }
  
  cal.actor @jpeg_io__Source__v__frames_300$spec_9448658579095253651(%arg0: i32)
    out_names ["Out"]
    ports_out (
      %arg1: !fifo.input_port<i8>
    )
  {
    %c300_i32 = arith.constant 300 : i32
    %c27 = arith.constant 27 : index
    %c64 = arith.constant 64 : index
    %c1000_i32 = arith.constant 1000 : i32
    %false = arith.constant false
    %c3867_i32 = arith.constant 3867 : i32
    %c0 = arith.constant 0 : index
    %c1_i32 = arith.constant 1 : i32
    %c1 = arith.constant 1 : index
    %c3840_i32 = arith.constant 3840 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c0_i32 : i32)
    %2 = cal.create_state_var<memref<3867xi8>> : !cal.state_ref<memref<3867xi8>>
    %3 = cal.get(%2 : !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
    %4 = memref.get_global @__cmr_3 : memref<3867xi8>
    memref.copy %4, %3 : memref<3867xi8> to memref<3867xi8>
    cal.action "$untagged0" priority=2
    {
      cal.predicate {
        %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %6 = arith.cmpi ult, %5, %c3840_i32 : i32
        cal.predicate_result %6 : i1
      }
      %alloca = memref.alloca() : memref<64xi8>
      scf.for %arg2 = %c0 to %c64 step %c1 {
        %5 = cal.get(%2 : !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
        %6 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %7 = arith.index_cast %6 : i32 to index
        %8 = memref.load %5[%7] : memref<3867xi8>
        memref.store %8, %alloca[%arg2] : memref<64xi8>
        %9 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %10 = arith.addi %9, %c1_i32 : i32
        cal.set(%0 : !cal.state_ref<i32>, %10 : i32)
      }
      scf.for %arg2 = %c0 to %c64 step %c1 {
        %5 = memref.load %alloca[%arg2] : memref<64xi8>
        fifo.push(%arg1 : !fifo.input_port<i8>, %5 : i8)
      }
    }
    
    cal.action "$untagged1" priority=2
    {
      cal.predicate {
        %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %6 = arith.cmpi uge, %5, %c3840_i32 : i32
        %7 = arith.cmpi ult, %5, %c3867_i32 : i32
        %8 = arith.select %6, %7, %false : i1
        cal.predicate_result %8 : i1
      }
      %alloca = memref.alloca() : memref<27xi8>
      scf.for %arg2 = %c0 to %c27 step %c1 {
        %5 = cal.get(%2 : !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
        %6 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %7 = arith.index_cast %6 : i32 to index
        %8 = memref.load %5[%7] : memref<3867xi8>
        memref.store %8, %alloca[%arg2] : memref<27xi8>
        %9 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %10 = arith.addi %9, %c1_i32 : i32
        cal.set(%0 : !cal.state_ref<i32>, %10 : i32)
      }
      scf.for %arg2 = %c0 to %c27 step %c1 {
        %5 = memref.load %alloca[%arg2] : memref<27xi8>
        fifo.push(%arg1 : !fifo.input_port<i8>, %5 : i8)
      }
    }
    
    cal.action "$untagged2" priority=2
    {
      cal.predicate {
        %12 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %13 = arith.cmpi eq, %12, %c3867_i32 : i32
        %14 = cal.get(%1 : !cal.state_ref<i32>) : i32
        %15 = arith.cmpi ult, %14, %c300_i32 : i32
        %16 = arith.select %13, %15, %false : i1
        cal.predicate_result %16 : i1
      }
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %5, %c1_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %6 : i32)
      %7 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %8 = arith.remui %7, %c1000_i32 : i32
      %9 = arith.cmpi eq, %8, %c0_i32 : i32
      scf.if %9 {
        %12 = cal.get(%1 : !cal.state_ref<i32>) : i32
        fifo.print("Finished sending frame %u\0A\00", %12) : (i32)
      }
      %10 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %11 = arith.cmpi ult, %10, %c300_i32 : i32
      scf.if %11 {
        cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
      }
    }
    
  }
  
}

