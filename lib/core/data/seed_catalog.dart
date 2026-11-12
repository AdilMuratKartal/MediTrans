import 'models/breath_cadence_model.dart';
import 'models/frequency_track_model.dart';
import 'models/mood_option_model.dart';
import 'models/playable_track_model.dart';
import 'models/session_category_model.dart';
import 'models/sleep_media_track_model.dart';
import 'models/yoga_pose_item_model.dart';

/// Complete Canonical Seed Catalog matching `data_referance.md`, `project.md`,
/// and the real WAV files in `mediTrack-tasarım-ve-assetler/UYGULAMA-ICI-SESLER/HZ-SESLERI`.
class SeedCatalog {
  static const List<MoodOption> moodCatalog = [
    MoodOption(code: 'mutlu', emoji: '😊', label: 'Mutlu', score: 5),
    MoodOption(code: 'huzurlu', emoji: '🥰', label: 'Huzurlu', score: 5),
    MoodOption(code: 'enerjik', emoji: '✨', label: 'Enerjik', score: 5),
    MoodOption(code: 'minnettar', emoji: '🙏', label: 'Minnettar', score: 5),
    MoodOption(code: 'umutlu', emoji: '🌈', label: 'Umutlu', score: 4),
    MoodOption(code: 'sakin', emoji: '😌', label: 'Sakin', score: 4),
    MoodOption(code: 'odakli', emoji: '🧘', label: 'Odaklı', score: 4),
    MoodOption(code: 'notr', emoji: '😐', label: 'Nötr', score: 3),
    MoodOption(code: 'dalgın', emoji: '😶‍🌫️', label: 'Dalgın', score: 3),
    MoodOption(code: 'hassas', emoji: '🥺', label: 'Hassas', score: 2),
    MoodOption(code: 'endisel', emoji: '😟', label: 'Endişeli', score: 2),
    MoodOption(code: 'uzgun', emoji: '😔', label: 'Üzgün', score: 2),
    MoodOption(code: 'yorgun', emoji: '😴', label: 'Yorgun', score: 2),
    MoodOption(code: 'stresli', emoji: '😣', label: 'Stresli', score: 1),
  ];

  static MoodOption findMood(String codeOrLabel) {
    final lower = codeOrLabel.toLowerCase();
    for (final m in moodCatalog) {
      if (m.code.toLowerCase() == lower || m.label.toLowerCase() == lower) {
        return m;
      }
    }
    return const MoodOption(
      code: 'sakin',
      emoji: '😌',
      label: 'Sakin',
      score: 4,
    );
  }

  static const List<BreathCadence> breathCadences = [
    BreathCadence(
      id: 'breath_4_1_4',
      titleTr: '4-1-4 Dengeli Solunum',
      subtitleTr: '4 sn Nefes Al • 1 sn Tut • 4 sn Yavaşça Ver',
      inhaleSec: 4,
      holdSec: 1,
      exhaleSec: 4,
      durationMinutesOptions: [5, 10, 15],
      localAudioAsset: 'assets/audio/breathwork/nefes_4_7_8.mp3',
      remoteStoragePath: 'breathwork/nefes_4_7_8.mp3',
      backgroundAsset: 'assets/images/backgrounds/breathwork_bg.jpg',
    ),
    BreathCadence(
      id: 'breath_4_7_8',
      titleTr: '4-7-8 Rahatlama Nefesi',
      subtitleTr: '4 sn Nefes Al • 7 sn Tut • 8 sn Derin Ver',
      inhaleSec: 4,
      holdSec: 7,
      exhaleSec: 8,
      durationMinutesOptions: [5, 10, 15],
      localAudioAsset: 'assets/audio/breathwork/nefes_4_7_8.mp3',
      remoteStoragePath: 'breathwork/nefes_4_7_8.mp3',
      backgroundAsset: 'assets/images/backgrounds/breathwork_bg.jpg',
    ),
  ];

  static const List<YogaPoseItem> yogaPoses = [
    YogaPoseItem(
      orderIndex: 1,
      id: 'pose_01_virasana',
      sanskritName: 'Virasana',
      turkishName: 'Kahraman Oturuşu',
      subtitleTr: 'Başlangıç • Topraklanma & Nefes Hazırlığı',
      levelBadgeTr: 'Başlangıç',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_01.png',
      stepInstructionsTr: [
        'Matın üzerinde diz çökerek ayak sırtlarını yere düz bir şekilde yerleştirin ve topuklarınızın arasına nazikçe oturun.',
        'Omurganızı yukarı doğru uzatın, omuzlarınızı kulaklarınızdan uzaklaştırarak avuç içlerinizi uyluklarınızın üzerine bırakın.',
        'Gözlerinizi yarı kapatarak burundan derin ve sakin nefesler alıp verin; bedeninizin ağırlığını yere teslim edin.',
      ],
      benefitBadgesTr: [
        'Topraklanma ve zihinsel odaklanma',
        'Ayak bilekleri ve diz eklemlerini esnetir',
        'Omurga hizasını dengeler',
      ],
    ),
    YogaPoseItem(
      orderIndex: 2,
      id: 'pose_02_marjariasana',
      sanskritName: 'Marjariasana',
      turkishName: 'Kedi-İnek Akışı',
      subtitleTr: 'Başlangıç • Omurga Mobilitesi & Ritmik Akış',
      levelBadgeTr: 'Başlangıç',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_02.png',
      stepInstructionsTr: [
        'Elleriniz omuzlarınızın, dizleriniz kalçalarınızın tam altında olacak şekilde dört ayak pozisyonuna yerleşin.',
        'Nefes alırken karnınızı aşağı doğru bırakıp göğüs kafesinizi ve bakışlarınızı nazikçe karşıya doğru açın.',
        'Nefes verirken çenenizi göğsünüze yaklaştırın, sırtınızı yukarı doğru yuvarlayarak kürek kemiklerinizi ayırın.',
      ],
      benefitBadgesTr: [
        'Omurga esnekliğini artırır',
        'Sırt ve boyun gerginliğini çözer',
        'Nefes ile hareketi senkronize eder',
      ],
    ),
    YogaPoseItem(
      orderIndex: 3,
      id: 'pose_03_sasangasana',
      sanskritName: 'Sasangasana',
      turkishName: 'Tavşan Pozu',
      subtitleTr: 'Orta Düzey • Derin Omurga Esnetme',
      levelBadgeTr: 'Orta Düzey',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_03.png',
      stepInstructionsTr: [
        'Dizlerinizin üzerine çökün ve topuklarınızı ellerinizle sıkıca kavrayın; başınızın tepesini dizlerinizin önüne yerleştirin.',
        'Nefes verirken kalçanızı tavana doğru kaldırarak sırtınızı derin bir yay şeklinde yuvarlayın.',
        'Boynunuza aşırı yük bindirmeden topuklarınızı tutmaya devam edin ve kürek kemiklerinizin açıldığını hissedin.',
      ],
      benefitBadgesTr: [
        'Üst sırt ve boyun fasyasını rahatlatır',
        'Beyne giden oksijen akışını destekler',
        'Sinir sistemini sakinleştirir',
      ],
    ),
    YogaPoseItem(
      orderIndex: 4,
      id: 'pose_04_adho_mukha',
      sanskritName: 'Adho Mukha Svanasana',
      turkishName: 'Aşağı Bakan Köpek',
      subtitleTr: 'Orta Düzey • Tüm Beden Uzama & Canlanma',
      levelBadgeTr: 'Orta Düzey',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_04.png',
      stepInstructionsTr: [
        'Ellerinizi omuz genişliğinde açarak parmaklarınızı matın üzerine yayın ve ayak parmaklarınızı takarak kalçanızı yukarı itin.',
        'Bedeninizle ters bir V şekli oluşturun; dizlerinizi hafif bükülü tutarak önce omurganızı uzatmaya odaklanın.',
        'Topuklarınızı yavaşça yere doğru ağırlaştırırken başınızı kollarınızın arasında serbest bırakın.',
      ],
      benefitBadgesTr: [
        'Arka bacak ve baldır kaslarını uzatır',
        'Omuz ve sırt kuşağını güçlendirir',
        'Zihinsel yorgunluğu hafifletir',
      ],
    ),
    YogaPoseItem(
      orderIndex: 5,
      id: 'pose_05_uttanasana',
      sanskritName: 'Uttanasana',
      turkishName: 'Ayakta Öne Katlanma',
      subtitleTr: 'Başlangıç • Teslimiyet & Arka Zincir Esneme',
      levelBadgeTr: 'Başlangıç',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_05.png',
      stepInstructionsTr: [
        'Ayaklarınız kalça genişliğinde açıkken derin bir nefes alın ve kalça ekleminden öne doğru yavaşça katlanın.',
        'Dizlerinizi hafifçe yumuşatarak göğsünüzü üst bacaklarınıza yaklaştırın; ellerinizle dirseklerinizi tutun veya yere dokunun.',
        'Başınızın ve boynunuzun ağırlığını tamamen yerçekimine bırakarak her nefes verişte biraz daha gevşeyin.',
      ],
      benefitBadgesTr: [
        'Merkezi sinir sistemini yatıştırır',
        'Hamstring ve bel bölgesini esnetir',
        'Stres ve zihinsel gerginliği azaltır',
      ],
    ),
    YogaPoseItem(
      orderIndex: 6,
      id: 'pose_06_ardha_uttanasana',
      sanskritName: 'Ardha Uttanasana',
      turkishName: 'Yarı Yol Açılma',
      subtitleTr: 'Orta Düzey • Postür & Sırt Güçlendirme',
      levelBadgeTr: 'Orta Düzey',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_06.png',
      stepInstructionsTr: [
        'Öne katlanma pozisyonundan nefes alırken ellerinizi kaval kemiklerinize veya uyluklarınıza yerleştirin.',
        'Göğsünüzü ileri doğru uzatarak sırtınızı yere paralel düz bir masa konumuna getirin.',
        'Boynunuzun arkasını uzun tutun, bakışlarınızı matın hemen önüne sabitleyin ve karın merkezini nazikçe aktif tutun.',
      ],
      benefitBadgesTr: [
        'Üst sırt kaslarını ve duruşu güçlendirir',
        'Göğüs kafesini açarak nefes kapasitesini artırır',
        'Omurga hizalanmasını geliştirir',
      ],
    ),
    YogaPoseItem(
      orderIndex: 7,
      id: 'pose_07_utkatasana',
      sanskritName: 'Utkatasana',
      turkishName: 'Sandalye Pozu',
      subtitleTr: 'Güç • İçsel Ateş & Merkez Dengesi',
      levelBadgeTr: 'Güç',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_07.png',
      stepInstructionsTr: [
        'Ayaklarınızı birleştirin veya kalça genişliğinde tutun; dizlerinizi bükerek görünmez bir sandalyeye oturur gibi kalçanızı geriye indirin.',
        'Kollarınızı kulaklarınızın yanından yukarı doğru uzatın, omuzlarınızı rahat bırakarak göğsünüzü dik tutun.',
        'Ağırlığınızı topuklarınıza verin ve alt karın kaslarınızı içeri toplayarak güçlü, ritmik nefesler alın.',
      ],
      benefitBadgesTr: [
        'Üst bacak, kalça ve merkez kaslarını güçlendirir',
        'İrade ve odaklanma enerjisini yükseltir',
        'Denge ve ayak bileği stabilitesini artırır',
      ],
    ),
    YogaPoseItem(
      orderIndex: 8,
      id: 'pose_08_savasana',
      sanskritName: 'Savasana',
      turkishName: 'Derin Dinlenme Pozu',
      subtitleTr: 'Dinlenme • Tam Entegrasyon & Bırakış',
      levelBadgeTr: 'Dinlenme',
      recommendedSeconds: 60,
      illustrationAsset: 'assets/images/yoga/pose_08.png',
      stepInstructionsTr: [
        'Sırtüstü uzanın, bacaklarınızı mat genişliğinde açarak ayak uçlarınızın iki yana doğalca düşmesine izin verin.',
        'Kollarınızı gövdenizin yanında avuç içleri yukarı bakacak şekilde yerleştirin ve çenenizi hafifçe göğsünüze yaklaştırın.',
        'Gözlerinizi kapatın; ayak parmaklarınızdan yüz kaslarınıza kadar tüm bedeninizi tarayarak her nefeste derin bir huzura bırakın.',
      ],
      benefitBadgesTr: [
        'Pratiğin tüm enerjisini bedene entegre eder',
        'Kalp ritmini ve kan basıncını dengeler',
        'Derin meditasyon ve içsel sessizlik sağlar',
      ],
    ),
  ];

  static const List<FrequencyTrack> frequencies = [
    // Real Binaural & Solfeggio WAVs from UYGULAMA-ICI-SESLER/HZ-SESLERI
    FrequencyTrack(
      id: 'hz_7_83',
      codeLabel: '7.83 Hz',
      frequencyValue: 7.83,
      titleTr: 'Schumann Rezonansı',
      chakraOrThemeTr: 'Dünya Kalp Atışı • Derin Topraklanma',
      descriptionTr:
          'Yerkürenin doğal elektromanyetik kalp atışı. Zihinsel dağınıklığı yatıştırır ve biyolojik ritmi doğayla uyumlar.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 4,
      localAudioAsset: 'assets/audio/frequencies/binaural_7_83hz.wav',
      remoteAudioStoragePath: 'frequencies/binaural_7_83hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_40',
      codeLabel: '40 Hz',
      frequencyValue: 40.0,
      titleTr: 'Gama Zirve Bilinç',
      chakraOrThemeTr: 'Binaural Gama • Berrak Zihin & Odak',
      descriptionTr:
          'Bilişsel berraklık, yüksek farkındalık ve zihinsel senkronizasyon sağlayan binaural gama frekansı.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 1,
      localAudioAsset: 'assets/audio/frequencies/binaural_40hz.wav',
      remoteAudioStoragePath: 'frequencies/binaural_40hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_136_1',
      codeLabel: '136.1 Hz',
      frequencyValue: 136.1,
      titleTr: 'Om Tonu • Dünya Yılı',
      chakraOrThemeTr: 'Kozmik Om Rezonansı • Kalp Merkezi',
      descriptionTr:
          'Dünyanın güneş etrafındaki yıllık dönüş frekansı (Om tonu). Derin meditasyon ve içsel huzur sağlar.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 3,
      localAudioAsset: 'assets/audio/frequencies/om_136_1hz.wav',
      remoteAudioStoragePath: 'frequencies/om_136_1hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_174',
      codeLabel: '174 Hz',
      frequencyValue: 174.0,
      titleTr: 'Ağrı & Gerginlik Azaltma',
      chakraOrThemeTr: 'Bedensel Rahatlama • Güven Hissi',
      descriptionTr:
          'Fiziksel gerginliği azaltmaya ve organlara derin bir güven, emniyet hissi vermeye odaklanan en alt Solfeggio tonu.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 0,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_174hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_174hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_285',
      codeLabel: '285 Hz',
      frequencyValue: 285.0,
      titleTr: 'Doku & Enerji Yenilenmesi',
      chakraOrThemeTr: 'Enerji Alanı Onarımı • Canlılık',
      descriptionTr:
          'Enerji bedenini tazeleyen ve yıpranmış duygusal alanların doğal formuna dönmesini destekleyen şifa rezonansı.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 2,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_285hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_285hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_396',
      codeLabel: '396 Hz',
      frequencyValue: 396.0,
      titleTr: 'Kök Çakra Özgürleşme',
      chakraOrThemeTr: 'Korku ve Kaygıdan Arınma',
      descriptionTr:
          'Bilinçaltındaki savunma mekanizmalarını, suçluluk ve endişe kalıplarını çözerek içsel gücü uyandırır.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 0,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_396hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_396hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_417',
      codeLabel: '417 Hz',
      frequencyValue: 417.0,
      titleTr: 'Sakral Çakra & Dönüşüm',
      chakraOrThemeTr: 'Olumsuz Kalıpları Çözme • Yaratıcılık',
      descriptionTr:
          'Geçmişin duygusal yüklerini temizleyen ve yaratıcı yaşam enerjisinin akışını açan Sakral Çakra tonu.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 2,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_417hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_417hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_432',
      codeLabel: '432 Hz',
      frequencyValue: 432.0,
      titleTr: 'Evrensel Uyum & Ruhsal Denge',
      chakraOrThemeTr: 'Doğal Akustik Denge • Kalp Huzuru',
      descriptionTr:
          'Evrenin matematiksel harmonisiyle örtüşen berrak frekans. Zihinsel gürültüyü sadeleştirir ve derin dinginlik yayar.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 1,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_432hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_432hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_528',
      codeLabel: '528 Hz',
      frequencyValue: 528.0,
      titleTr: 'Mucize Frekansı & DNA Onarımı',
      chakraOrThemeTr: 'Solar Pleksus • Dönüşüm & Sevgi',
      descriptionTr:
          'Yaşam enerjisini yükselten, kalp ve zihin arasındaki yaratıcı potansiyeli uyandıran altın Solfeggio frekansı.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 2,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_528hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_528hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_639',
      codeLabel: '639 Hz',
      frequencyValue: 639.0,
      titleTr: 'Kalp Çakrası & Empati',
      chakraOrThemeTr: 'İlişkisel Uyum • Şefkat',
      descriptionTr:
          'Kendinizle ve çevrenizle kurduğunuz bağı yumuşatan, anlayış, sevgi ve hoşgörüyü besleyen kalp rezonansı.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 3,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_639hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_639hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_741',
      codeLabel: '741 Hz',
      frequencyValue: 741.0,
      titleTr: 'Boğaz Çakrası & Sezgi Uyanışı',
      chakraOrThemeTr: 'Zihinsel Detoks • Öz İfade',
      descriptionTr:
          'Düşünsel bulanıklığı temizleyen, iç sesi özgürce ifade etmeye ve yaratıcı çözümlere alan açan frekans.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 5,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_741hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_741hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_852',
      codeLabel: '852 Hz',
      frequencyValue: 852.0,
      titleTr: 'Üçüncü Göz & İçsel Bilgelik',
      chakraOrThemeTr: 'Derin Sezgi • Ruhsal Berraklık',
      descriptionTr:
          'Yüzeysel düşüncelerin ötesindeki içgörüyü uyandırır; berrak rüya ve derin tefekkür pratiğini destekler.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 6,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_852hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_852hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_963',
      codeLabel: '963 Hz',
      frequencyValue: 963.0,
      titleTr: 'Tepe Çakra & Saf Bilinç',
      chakraOrThemeTr: 'İlahi Uyum • Birlik Hissi',
      descriptionTr:
          'Taç çakrayı aktive ederek sessiz, zamansız bir bütünlük ve ışık hissi uyandıran en yüksek Solfeggio tonu.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 7,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_963hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_963hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_10_alpha',
      codeLabel: '10 Hz',
      frequencyValue: 10.0,
      titleTr: 'Alpha Odaklanma & Dinginlik',
      chakraOrThemeTr: 'Binaural Alpha • Sakin Konsantrasyon',
      descriptionTr:
          'Zihni stresten arındırırken öğrenme, okuma ve yaratıcı akış halini destekleyen binaural alpha dalgası.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 4,
      localAudioAsset: 'assets/audio/frequencies/binaural_10hz.wav',
      remoteAudioStoragePath: 'frequencies/binaural_10hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_4_5_theta',
      codeLabel: '4.5 Hz',
      frequencyValue: 4.5,
      titleTr: 'Theta Derin Meditasyon',
      chakraOrThemeTr: 'Binaural Theta • İçsel Yolculuk',
      descriptionTr:
          'Derin meditasyon, sezgisel görüler ve bilinçaltı gevşeme sağlayan binaural theta frekansı.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 6,
      localAudioAsset: 'assets/audio/frequencies/binaural_4_5hz.wav',
      remoteAudioStoragePath: 'frequencies/binaural_4_5hz.wav',
    ),
    FrequencyTrack(
      id: 'hz_2_delta',
      codeLabel: '2 Hz',
      frequencyValue: 2.0,
      titleTr: 'Delta Derin Uyku & Yenilenme',
      chakraOrThemeTr: 'Binaural Delta • Hücresel Dinlenme',
      descriptionTr:
          'Rüyasız derin uyku ve bedensel onarım evresini destekleyen en yavaş binaural beyin dalgası.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 8,
      localAudioAsset: 'assets/audio/frequencies/binaural_2hz.wav',
      remoteAudioStoragePath: 'frequencies/binaural_2hz.wav',
    ),

    // Angel Sequences (111 .. 999) mapped to real Solfeggio/Binaural WAV files
    FrequencyTrack(
      id: 'angel_111',
      codeLabel: '111',
      frequencyValue: 111.0,
      isAngelSequence: true,
      titleTr: 'Yeni Başlangıç & Niyet',
      chakraOrThemeTr: 'Melek Dizisi • Saf Odak',
      descriptionTr:
          'Zihinsel niyetlerinizi berraklaştıran ve yeni bir döngüye adım atarken içsel cesareti uyandıran rezonans.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 0,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_174hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_174hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_222',
      codeLabel: '222',
      frequencyValue: 222.0,
      isAngelSequence: true,
      titleTr: 'Uyum & İlahi Zamanlama',
      chakraOrThemeTr: 'Melek Dizisi • Güven ve Sabır',
      descriptionTr:
          'Hayatın akışına güvenmeyi hatırlatan, duygusal dalgalanmaları dengeleyen yumuşak armonik ton.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 1,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_285hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_285hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_333',
      codeLabel: '333',
      frequencyValue: 333.0,
      isAngelSequence: true,
      titleTr: 'Zihin-Beden-Ruh Dengesi',
      chakraOrThemeTr: 'Melek Dizisi • Yaratıcı İfade',
      descriptionTr:
          'İçsel rehberliği ve neşeli yaşam enerjisini uyandıran üçlü birlik frekansı.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 2,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_396hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_396hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_444',
      codeLabel: '444',
      frequencyValue: 444.0,
      isAngelSequence: true,
      titleTr: 'Korunma & İçsel Kale',
      chakraOrThemeTr: 'Melek Dizisi • Sarsılmaz Huzur',
      descriptionTr:
          'Bulunduğunuz anda güvende ve desteklenmiş hissetmenizi sağlayan topraklayıcı kalkan tonu.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 3,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_432hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_432hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_555',
      codeLabel: '555',
      frequencyValue: 555.0,
      isAngelSequence: true,
      titleTr: 'Büyük Dönüşüm & Akış',
      chakraOrThemeTr: 'Melek Dizisi • Yenilenme',
      descriptionTr:
          'Eski alışkanlık kalıplarını geride bırakıp değişimi zarafetle kucaklamaya yardımcı olan frekans.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 4,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_528hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_528hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_666',
      codeLabel: '666',
      frequencyValue: 666.0,
      isAngelSequence: true,
      titleTr: 'Öz Şefkat & Dünyevi Denge',
      chakraOrThemeTr: 'Melek Dizisi • İçsel Barış',
      descriptionTr:
          'Maddi kaygılardan sıyrılıp dikkati yeniden kalbin sıcaklığına ve öz bakıma yönelten denge tonu.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 5,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_639hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_639hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_777',
      codeLabel: '777',
      frequencyValue: 777.0,
      isAngelSequence: true,
      titleTr: 'Ruhsal Uyanış & Şans',
      chakraOrThemeTr: 'Melek Dizisi • Derin Bilgelik',
      descriptionTr:
          'İçsel sessizlikte saklı olan bilgeliği ve eşzamanlılıkları fark etmeyi kolaylaştıran mistik ton.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 6,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_741hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_741hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_888',
      codeLabel: '888',
      frequencyValue: 888.0,
      isAngelSequence: true,
      titleTr: 'Sonsuz Bereket & Denge',
      chakraOrThemeTr: 'Melek Dizisi • Enerji Döngüsü',
      descriptionTr:
          'Alma ve verme dengesini uyumlayan, yaşam enerjisinin kesintisiz akışını simgeleyen rezonans.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 7,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_852hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_852hz.wav',
    ),
    FrequencyTrack(
      id: 'angel_999',
      codeLabel: '999',
      frequencyValue: 999.0,
      isAngelSequence: true,
      titleTr: 'Arınma & Tamamlanma (Release)',
      chakraOrThemeTr: 'Melek Dizisi • Bırakış & Özgürlük',
      descriptionTr:
          'Artık size hizmet etmeyen duygusal yükleri sevgiyle uğurlayıp yeni bir sayfaya hazırlanma frekansı.',
      backgroundAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
      styleIndex: 8,
      localAudioAsset: 'assets/audio/frequencies/solfeggio_963hz.wav',
      remoteAudioStoragePath: 'frequencies/solfeggio_963hz.wav',
    ),
  ];

  static const List<SleepMediaTrack> natureTracks = [
    SleepMediaTrack(
      id: 'nature_rain',
      category: SessionCategory.natureSound,
      titleTr: 'Gece Yağmuru',
      subtitleTr: '5 Dakika Sakin Yağmur Sesi • Doğal Akustik',
      backgroundAsset: 'assets/images/backgrounds/nature_rain_bg.jpg',
      localAudioAsset: 'assets/audio/nature/sakin_yagmur_5dk.mp3',
      remoteStoragePath: 'nature/sakin_yagmur_5dk.mp3',
      durationSeconds: 300,
    ),
    SleepMediaTrack(
      id: 'nature_ocean',
      category: SessionCategory.natureSound,
      titleTr: 'Derin Okyanus',
      subtitleTr: 'Ritmik Kıyı Dalgaları • Gece Dinginliği',
      backgroundAsset: 'assets/images/backgrounds/nature_ocean_bg.jpg',
      localAudioAsset: 'assets/audio/nature/deep_ocean_shortened.m4a',
      remoteStoragePath: 'nature/deep_ocean_shortened.m4a',
      durationSeconds: 540,
    ),
  ];

  static const List<SleepMediaTrack> noiseTracks = [
    SleepMediaTrack(
      id: 'noise_white',
      category: SessionCategory.noiseSound,
      titleTr: 'Beyaz Gürültü',
      subtitleTr: 'Dengeli Spektrum • Dış Ses İzolasyonu',
      backgroundAsset: 'assets/images/backgrounds/noise_white_bg.jpg',
      localAudioAsset: 'assets/audio/noise/beyaz_gurultu.mp3',
      remoteStoragePath: 'noise/beyaz_gurultu.mp3',
      durationSeconds: 300,
    ),
    SleepMediaTrack(
      id: 'noise_brown',
      category: SessionCategory.noiseSound,
      titleTr: 'Kahverengi Gürültü',
      subtitleTr: 'Derin Bas Frekanslı Akustik Battaniye',
      backgroundAsset: 'assets/images/backgrounds/noise_brown_bg.jpg',
      localAudioAsset: 'assets/audio/noise/kahverengi_gurultu.m4a',
      remoteStoragePath: 'noise/kahverengi_gurultu.m4a',
      durationSeconds: 600,
    ),
  ];

  static const List<SleepMediaTrack> storyTracks = [
    SleepMediaTrack(
      id: 'story_1',
      category: SessionCategory.sleepStory,
      titleTr: 'Ay Işığında Gizli Orman ve Sakin Göl',
      subtitleTr: 'Hikaye 1 • Sesli Uyku Masalı & Tam Metin',
      backgroundAsset: 'assets/images/backgrounds/story_1_bg.jpg',
      localAudioAsset: 'assets/audio/stories/hikaye_1.mp3',
      remoteStoragePath: 'stories/hikaye_1.mp3',
      storyTextAsset: 'assets/stories/hikaye_1.txt',
      durationSeconds: 360,
    ),
    SleepMediaTrack(
      id: 'story_2',
      category: SessionCategory.sleepStory,
      titleTr: 'Yıldızların Altında Gizli Dağ Kulübesi',
      subtitleTr: 'Hikaye 2 • Sesli Uyku Masalı & Tam Metin',
      backgroundAsset: 'assets/images/backgrounds/story_2_bg.jpg',
      localAudioAsset: 'assets/audio/stories/hikaye_2.mp3',
      remoteStoragePath: 'stories/hikaye_2.mp3',
      storyTextAsset: 'assets/stories/hikaye_2.txt',
      durationSeconds: 300,
    ),
  ];

  static PlayableTrack fromFrequency(FrequencyTrack f) {
    return PlayableTrack(
      id: f.id,
      title: '${f.codeLabel} • ${f.titleTr}',
      subtitle: f.chakraOrThemeTr,
      category: SessionCategory.frequency,
      localAudioAsset: f.localAudioAsset,
      remoteStoragePath: f.remoteAudioStoragePath,
      backgroundAsset: f.backgroundAsset,
      durationSeconds: f.defaultDurationSeconds,
      frequencyHz: f.frequencyValue,
    );
  }

  static PlayableTrack fromSleepTrack(SleepMediaTrack s) {
    return PlayableTrack(
      id: s.id,
      title: s.titleTr,
      subtitle: s.subtitleTr,
      category: s.category,
      localAudioAsset: s.localAudioAsset,
      remoteStoragePath: s.remoteStoragePath,
      backgroundAsset: s.backgroundAsset,
      durationSeconds: s.durationSeconds,
    );
  }

  static PlayableTrack fromBreathCadence(BreathCadence b) {
    return PlayableTrack(
      id: b.id,
      title: b.titleTr,
      subtitle: b.subtitleTr,
      category: SessionCategory.breathwork,
      localAudioAsset: b.localAudioAsset,
      remoteStoragePath: b.remoteStoragePath,
      backgroundAsset: b.backgroundAsset,
      durationSeconds: 300,
    );
  }

  static PlayableTrack? findPlayableById(String id) {
    for (final f in frequencies) {
      if (f.id == id) return fromFrequency(f);
    }
    for (final n in natureTracks) {
      if (n.id == id) return fromSleepTrack(n);
    }
    for (final n in noiseTracks) {
      if (n.id == id) return fromSleepTrack(n);
    }
    for (final s in storyTracks) {
      if (s.id == id) return fromSleepTrack(s);
    }
    for (final b in breathCadences) {
      if (b.id == id) return fromBreathCadence(b);
    }
    return null;
  }
}
