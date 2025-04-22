import 'package:flutter/material.dart';
import '../models/grammar_topic.dart';

class GrammarData {
  static List<GrammarTopic> topics = [
    // SIMPLE PRESENT (GENİŞ ZAMAN)
    GrammarTopic(
      id: '1-1',
      title: 'Simple Present (Geniş Zaman)',
      description:
          'Alışkanlıklar, genel gerçekler ve düzenli tekrarlanan eylemler için kullanılır.',
      examples: [
        'I wake up at 7 AM every day. (Her gün saat 7\'de uyanırım.)',
        'Water boils at 100°C. (Su 100°C\'de kaynar.)',
        'She doesn\'t like coffee. (O kahveyi sevmez.)',
        'Do you speak English? (İngilizce konuşur musun?)',
      ],
      color: '#4CAF50',
      iconPath: 'assets/icons/simple_present.svg',
      grammar_structure:
          'Geniş zaman (Simple Present), günlük rutinleri, alışkanlıkları, genel doğruları ve bilimsel gerçekleri ifade etmek için kullanılan bir zaman yapısıdır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - I/you/we/they + V1 (fiilin yalın hali)\n'
          '     Örnek: "I work every day." (Her gün çalışırım.)\n'
          '     Örnek: "You live in Istanbul." (İstanbul\'da yaşarsın.)\n'
          '   - He/she/it + V1 + s/es\n'
          '     Örnek: "He works in a bank." (O bir bankada çalışır.)\n'
          '     Örnek: "She lives in Ankara." (O Ankara\'da yaşar.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - I/you/we/they + do not (don\'t) + V1\n'
          '     Örnek: "I don\'t like coffee." (Kahveyi sevmem.)\n'
          '     Örnek: "They don\'t work on Sundays." (Onlar Pazar günleri çalışmazlar.)\n'
          '   - He/she/it + does not (doesn\'t) + V1\n'
          '     Örnek: "He doesn\'t speak French." (O Fransızca konuşmaz.)\n'
          '     Örnek: "It doesn\'t rain much in summer." (Yazın çok yağmur yağmaz.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Do + I/you/we/they + V1...?\n'
          '     Örnek: "Do you live here?" (Burada mı yaşıyorsun?)\n'
          '     Örnek: "Do they work together?" (Onlar birlikte mi çalışıyorlar?)\n'
          '   - Does + he/she/it + V1...?\n'
          '     Örnek: "Does she like music?" (O müziği sever mi?)\n'
          '     Örnek: "Does it open at 9 AM?" (Saat 9\'da mı açılır?)\n\n'
          '4. Üçüncü tekil şahıs için (he/she/it) özel kurallar:\n'
          '   - Genel kural: fiil + s (work → works, play → plays)\n'
          '     Örnek: "He works hard." (O sıkı çalışır.)\n'
          '   - ch, sh, ss, x, o ile biten fiiller: fiil + es (watch → watches, go → goes)\n'
          '     Örnek: "She watches TV every evening." (O her akşam TV izler.)\n'
          '   - Ünsüz + y ile biten fiiller: y → i + es (study → studies, cry → cries)\n'
          '     Örnek: "He studies English." (O İngilizce çalışır.)\n'
          '   - Ünlü + y ile biten fiiller: fiil + s (play → plays, say → says)\n'
          '     Örnek: "She plays tennis." (O tenis oynar.)\n\n'
          '5. Özel durum fiiller:\n'
          '   - have → has (he/she/it için): "She has a car." (Onun bir arabası var.)\n'
          '   - do → does (he/she/it için): "He does his homework." (O ödevini yapar.)\n\n'
          '6. Geniş zamanın kullanım amaçları:\n'
          '   - Alışkanlıklar ve rutinler: "I drink coffee every morning." (Her sabah kahve içerim.)\n'
          '   - Genel doğrular: "The Earth revolves around the Sun." (Dünya Güneş\'in etrafında döner.)\n'
          '   - Değişmeyen durumlar: "I live in Turkey." (Türkiye\'de yaşarım.)\n'
          '   - Tarifeler ve talimatlar: "First, you mix the ingredients." (Önce malzemeleri karıştırırsın.)\n'
          '   - Zaman çizelgeleri: "The train arrives at 5 PM." (Tren saat 5\'te varır.)\n\n'
          '7. Geniş zamanla sıklıkla kullanılan zaman zarfları:\n'
          '   - always (her zaman), usually (genellikle), often (sık sık)\n'
          '   - sometimes (bazen), rarely (nadiren), never (asla)\n'
          '   - every day/week/month/year (her gün/hafta/ay/yıl)',
      subtopics: [],
    ),

    // PRESENT CONTINUOUS (ŞİMDİKİ ZAMAN)
    GrammarTopic(
      id: '1-2',
      title: 'Present Continuous (Şimdiki Zaman)',
      description: 'Şu anda devam eden eylemler için kullanılır.',
      examples: [
        'I am studying right now. (Şu anda ders çalışıyorum.)',
        'He is playing football with his friends. (Arkadaşlarıyla futbol oynuyor.)',
        'They are not working today. (Bugün çalışmıyorlar.)',
        'Are you listening to me? (Beni dinliyor musun?)',
      ],
      color: '#4CAF50',
      iconPath: 'assets/icons/present_continuous.svg',
      grammar_structure:
          'Şimdiki zaman (Present Continuous), şu anda devam eden veya yakın gelecekte planlanan eylemleri ifade etmek için kullanılan bir zaman yapısıdır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - I + am + Ving\n'
          '     Örnek: "I am reading a book." (Bir kitap okuyorum.)\n'
          '   - You/we/they + are + Ving\n'
          '     Örnek: "You are watching TV." (Televizyon izliyorsun.)\n'
          '     Örnek: "They are playing football." (Futbol oynuyorlar.)\n'
          '   - He/she/it + is + Ving\n'
          '     Örnek: "She is studying for her exam." (Sınavı için ders çalışıyor.)\n'
          '     Örnek: "It is raining." (Yağmur yağıyor.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - I + am not (\'m not) + Ving\n'
          '     Örnek: "I\'m not sleeping." (Uyumuyorum.)\n'
          '   - You/we/they + are not (aren\'t) + Ving\n'
          '     Örnek: "You aren\'t listening." (Dinlemiyorsun.)\n'
          '     Örnek: "They aren\'t working today." (Bugün çalışmıyorlar.)\n'
          '   - He/she/it + is not (isn\'t) + Ving\n'
          '     Örnek: "He isn\'t playing guitar." (Gitar çalmıyor.)\n'
          '     Örnek: "She isn\'t cooking dinner." (Akşam yemeği pişirmiyor.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Am + I + Ving...?\n'
          '     Örnek: "Am I disturbing you?" (Seni rahatsız ediyor muyum?)\n'
          '   - Are + you/we/they + Ving...?\n'
          '     Örnek: "Are you studying English?" (İngilizce mi çalışıyorsun?)\n'
          '     Örnek: "Are they coming tonight?" (Bu gece geliyorlar mı?)\n'
          '   - Is + he/she/it + Ving...?\n'
          '     Örnek: "Is she waiting for us?" (Bizi mi bekliyor?)\n'
          '     Örnek: "Is it working properly?" (Düzgün çalışıyor mu?)\n\n'
          '4. -ing ekini alma kuralları:\n'
          '   - Genel kural: fiil + ing (play → playing, walk → walking)\n'
          '     Örnek: "I am walking to school." (Okula yürüyorum.)\n'
          '   - "e" ile biten fiiller: e → ing (come → coming, write → writing)\n'
          '     Örnek: "She is writing a letter." (Bir mektup yazıyor.)\n'
          '   - Tek heceli, kısa ünlülü, tek sessiz ile biten fiiller: son sessiz ikiye katlanır + ing (run → running, sit → sitting)\n'
          '     Örnek: "They are running in the park." (Parkta koşuyorlar.)\n'
          '   - "ie" ile biten fiiller: ie → y + ing (lie → lying, die → dying)\n'
          '     Örnek: "She is lying on the beach." (Plajda uzanıyor.)\n\n'
          '5. Şimdiki zamanın kullanım amaçları:\n'
          '   - Şu anda devam eden eylemler: "I am cooking dinner right now." (Şu anda akşam yemeği pişiriyorum.)\n'
          '   - Geçici durumlar: "She is living with her parents until she finds a new apartment." (Yeni bir daire bulana kadar ailesiyle yaşıyor.)\n'
          '   - Yakın gelecek için planlanan eylemler: "We are meeting at 6 PM tonight." (Bu akşam saat 6\'da buluşuyoruz.)\n'
          '   - Değişim gösteren durumlar: "The population is increasing rapidly." (Nüfus hızla artıyor.)\n'
          '   - Tekrarlanan ve rahatsız edici eylemler (always, constantly, continuously ile): "She is always complaining." (O sürekli şikayet ediyor.)\n\n'
          '6. Şimdiki zamanla sıklıkla kullanılan zaman zarfları:\n'
          '   - now (şimdi), right now (şu anda), at the moment (şu an)\n'
          '   - today (bugün), this week/month (bu hafta/ay)\n'
          '   - Look! (Bak!), Listen! (Dinle!)\n\n'
          '7. Şimdiki zamanda genellikle kullanılmayan fiiller:\n'
          '   - Durum bildiren (stative) fiiller: like, love, hate, want, need, prefer\n'
          '     Örnek: "I like chocolate." (Çikolatayı severim.) (I am liking chocolate. - YANLIŞ)\n'
          '   - Algı fiilleri: see, hear, smell, taste\n'
          '     Örnek: "I see what you mean." (Ne demek istediğini anlıyorum.) (I am seeing what you mean. - YANLIŞ)\n'
          '   - Düşünme fiilleri: think, believe, understand, know, remember\n'
          '     Örnek: "I think you\'re right." (Haklı olduğunu düşünüyorum.) (I am thinking you\'re right. - YANLIŞ)\n'
          '   - Sahiplik fiilleri: have, own, belong\n'
          '     Örnek: "She has two cars." (İki arabası var.) (She is having two cars. - YANLIŞ)',
      subtopics: [],
    ),

    // PRESENT PERFECT (YAKIN GEÇMİŞ ZAMAN)
    GrammarTopic(
      id: '1-3',
      title: 'Present Perfect (Yakın Geçmiş Zaman)',
      description:
          'Geçmişte başlayan ve şu ana kadar devam eden eylemler için kullanılır.',
      examples: [
        'I have lived in Istanbul for 5 years. (5 yıldır İstanbul\'da yaşıyorum.)',
        'She has never been to Paris. (O hiç Paris\'e gitmedi.)',
        'Have you ever tried sushi? (Hiç suşi denedin mi?)',
        'They have already finished their homework. (Onlar ödevlerini çoktan bitirdiler.)',
      ],
      color: '#4CAF50',
      iconPath: 'assets/icons/present_perfect.svg',
      grammar_structure:
          'Yakın geçmiş zaman (Present Perfect), geçmişte yaşanmış ama şimdiki zamanla bağlantısı olan olayları ifade etmek için kullanılan bir zaman yapısıdır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - I/you/we/they + have + past participle (V3)\n'
          '     Örnek: "I have seen that movie." (O filmi gördüm.)\n'
          '     Örnek: "They have visited London." (Londra\'yı ziyaret ettiler.)\n'
          '   - He/she/it + has + past participle (V3)\n'
          '     Örnek: "She has finished her homework." (Ödevini bitirdi.)\n'
          '     Örnek: "He has lived here for ten years." (On yıldır burada yaşıyor.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - I/you/we/they + have not (haven\'t) + past participle\n'
          '     Örnek: "I haven\'t read that book." (O kitabı okumadım.)\n'
          '     Örnek: "We haven\'t decided yet." (Henüz karar vermedik.)\n'
          '   - He/she/it + has not (hasn\'t) + past participle\n'
          '     Örnek: "She hasn\'t called me." (Beni aramadı.)\n'
          '     Örnek: "It hasn\'t rained for months." (Aylardır yağmur yağmadı.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Have + I/you/we/they + past participle...?\n'
          '     Örnek: "Have you ever been to Rome?" (Hiç Roma\'ya gittin mi?)\n'
          '     Örnek: "Have they arrived yet?" (Henüz vardılar mı?)\n'
          '   - Has + he/she/it + past participle...?\n'
          '     Örnek: "Has she finished her exam?" (Sınavını bitirdi mi?)\n'
          '     Örnek: "Has the movie started?" (Film başladı mı?)\n\n'
          '4. Yakın geçmiş zamanın kullanım amaçları:\n'
          '   - Geçmişte başlayıp hala devam eden durumlar:\n'
          '     Örnek: "I have lived in Istanbul for five years." (Beş yıldır İstanbul\'da yaşıyorum.)\n'
          '     Örnek: "She has worked at this company since 2015." (2015\'ten beri bu şirkette çalışıyor.)\n'
          '   - Geçmişte yaşanmış ve şimdi etkisi devam eden deneyimler:\n'
          '     Örnek: "I have broken my arm." (Kolumu kırdım. - Hala alçıda olabilir.)\n'
          '     Örnek: "She has lost her keys." (Anahtarlarını kaybetti. - Hala bulamadı.)\n'
          '   - Henüz tamamlanmamış zaman diliminde gerçekleşen eylemler:\n'
          '     Örnek: "I have drunk three cups of coffee today." (Bugün üç fincan kahve içtim.)\n'
          '     Örnek: "She has seen five movies this week." (Bu hafta beş film izledi.)\n'
          '   - Hayat deneyimleri (zaman belirtilmeden):\n'
          '     Örnek: "I have been to Paris twice." (Paris\'e iki kez gittim.)\n'
          '     Örnek: "She has met many famous people." (Birçok ünlü insanla tanıştı.)\n\n'
          '5. Yakın geçmiş zamanda sıklıkla kullanılan zaman zarfları:\n'
          '   - for + süre (... boyunca): for two hours, for six months, for a long time\n'
          '   - since + başlangıç zamanı (... -den beri): since 2010, since Monday, since I was a child\n'
          '   - ever (hiç), never (hiç ... -mamak/-memek)\n'
          '   - already (çoktan), yet (henüz - olumsuz cümle ve sorularda)\n'
          '   - just (yeni/az önce), recently (son zamanlarda), lately (son günlerde/yakın zamanda)\n'
          '   - today (bugün), this week/month/year (bu hafta/ay/yıl)\n\n'
          '6. Present Perfect ve Simple Past arasındaki fark:\n'
          '   - Simple Past: Geçmişte belirli bir zamanda olan ve biten eylemler için kullanılır.\n'
          '     Örnek: "I visited Paris last year." (Geçen yıl Paris\'i ziyaret ettim.)\n'
          '   - Present Perfect: Geçmişle şimdi arasında bağlantı kuran, zamanı belirtilmeyen veya henüz tamamlanmamış zaman diliminde gerçekleşen eylemler için kullanılır.\n'
          '     Örnek: "I have visited Paris." (Paris\'i ziyaret ettim. - Ne zaman olduğunu belirtmez.)',
      subtopics: [],
    ),

    // SIMPLE PAST (GEÇMİŞ ZAMAN)
    GrammarTopic(
      id: '4',
      title: 'Simple Past (Geçmiş Zaman)',
      description: 'Geçmişte tamamlanmış eylemler için kullanılır.',
      examples: [
        'I visited Paris last summer. (Geçen yaz Paris\'i ziyaret ettim.)',
        'She didn\'t go to the party. (O partiye gitmedi.)',
        'Did you see that movie? (O filmi izledin mi?)',
        'They lived in London for 5 years. (5 yıl boyunca Londra\'da yaşadılar.)',
        'When I was a child, I played the piano. (Çocukken piyano çalardım.)',
      ],
      color: '#673AB7',
      iconPath: 'assets/icons/past_tense.svg',
      grammar_structure:
          'Geçmiş zaman (Simple Past), geçmişte belirli bir zamanda tamamlanmış eylemler için kullanılan bir zaman yapısıdır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - Tüm özneler (I/you/he/she/it/we/they) + V2 (geçmiş zaman fiili)\n'
          '     Örnek: "I worked yesterday." (Dün çalıştım.)\n'
          '     Örnek: "She visited her grandmother." (Büyükannesini ziyaret etti.)\n'
          '   - Düzenli fiiller: V1 + ed (work → worked, play → played)\n'
          '     Örnek: "They cleaned the house." (Evi temizlediler.)\n'
          '   - Düzensiz fiiller: İkinci form (go → went, see → saw, take → took)\n'
          '     Örnek: "He went to London." (Londra\'ya gitti.)\n'
          '     Örnek: "We saw a good movie." (İyi bir film gördük.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - Tüm özneler + did not (didn\'t) + V1 (fiilin yalın hali)\n'
          '     Örnek: "I didn\'t work yesterday." (Dün çalışmadım.)\n'
          '     Örnek: "She didn\'t visit her grandmother." (Büyükannesini ziyaret etmedi.)\n'
          '     Örnek: "They didn\'t go to the party." (Partiye gitmediler.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Did + özne + V1...?\n'
          '     Örnek: "Did you work yesterday?" (Dün çalıştın mı?)\n'
          '     Örnek: "Did she visit her grandmother?" (Büyükannesini ziyaret etti mi?)\n'
          '     Örnek: "Did they go to the party?" (Partiye gittiler mi?)\n\n'
          '4. Düzenli fiillerin yazılışı:\n'
          '   - Genel kural: V1 + ed (play → played, work → worked)\n'
          '     Örnek: "He played football." (Futbol oynadı.)\n'
          '   - Sessiz + y ile biten fiiller: y → i + ed (study → studied, try → tried)\n'
          '     Örnek: "She studied all night." (Bütün gece çalıştı.)\n'
          '   - Tek heceli, tek sessiz + kısa ünlü ile biten fiiller: son sessiz ikiye katlanır + ed (stop → stopped, plan → planned)\n'
          '     Örnek: "They stopped the car." (Arabayı durdurdular.)\n'
          '   - e ile biten fiiller: sadece d eklenir (live → lived, love → loved)\n'
          '     Örnek: "We lived in Paris." (Paris\'te yaşadık.)\n\n'
          '5. Düzensiz fiiller örnekleri:\n'
          '   - go → went (gitmek): "I went to the cinema." (Sinemaya gittim.)\n'
          '   - see → saw (görmek): "She saw her friend." (Arkadaşını gördü.)\n'
          '   - have → had (sahip olmak): "They had a good time." (İyi vakit geçirdiler.)\n'
          '   - make → made (yapmak): "He made a cake." (Pasta yaptı.)\n'
          '   - come → came (gelmek): "They came to the party." (Partiye geldiler.)\n\n'
          '6. Geçmiş zamanın kullanım amaçları:\n'
          '   - Geçmişte gerçekleşmiş ve bitmiş eylemler: "I visited Rome last year." (Geçen yıl Roma\'yı ziyaret ettim.)\n'
          '   - Belirli bir zaman noktasında gerçekleşen eylemler: "She arrived at 5 PM." (Saat 5\'te vardı.)\n'
          '   - Ardışık geçmiş eylemler: "He got up, had breakfast, and went to work." (Kalktı, kahvaltı yaptı ve işe gitti.)\n'
          '   - Geçmişteki alışkanlıklar veya durumlar: "I lived in London for five years." (Beş yıl Londra\'da yaşadım.)\n\n'
          '7. Geçmiş zamanla sıklıkla kullanılan zaman belirteçleri:\n'
          '   - yesterday (dün), last week/month/year (geçen hafta/ay/yıl)\n'
          '   - x ago (x zaman önce): two days ago (iki gün önce), a long time ago (uzun zaman önce)\n'
          '   - in + geçmiş yıl: in 2010, in 1995\n'
          '   - when I was young (ben gençken), when I was a child (ben çocukken)',
      subtopics: [],
    ),

    // PAST CONTINUOUS (GEÇMİŞTE DEVAM EDEN ZAMAN)
    GrammarTopic(
      id: '5',
      title: 'Past Continuous (Geçmişte Devam Eden Zaman)',
      description:
          'Geçmişte belirli bir zamanda devam eden eylemler için kullanılır.',
      examples: [
        'I was watching TV when she called. (O aradığında TV izliyordum.)',
        'They were playing football at 7 PM yesterday. (Dün akşam 7\'de futbol oynuyorlardı.)',
        'What were you doing last night? (Dün gece ne yapıyordun?)',
        'She wasn\'t sleeping when I got home. (Eve geldiğimde uyumuyordu.)',
      ],
      color: '#9C27B0',
      iconPath: 'assets/icons/past_continuous.svg',
      grammar_structure:
          'Geçmiş zaman hikayesi (Past Continuous), geçmişte belirli bir zamanda devam eden veya sürmekte olan eylemleri ifade etmek için kullanılan bir zaman yapısıdır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - I/He/She/It + was + Ving\n'
          '     Örnek: "I was reading a book." (Bir kitap okuyordum.)\n'
          '     Örnek: "She was waiting for the bus." (Otobüsü bekliyordu.)\n'
          '   - You/We/They + were + Ving\n'
          '     Örnek: "They were playing football." (Futbol oynuyorlardı.)\n'
          '     Örnek: "We were having dinner." (Akşam yemeği yiyorduk.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - I/He/She/It + was not (wasn\'t) + Ving\n'
          '     Örnek: "I wasn\'t sleeping." (Uyumuyordum.)\n'
          '     Örnek: "He wasn\'t listening." (Dinlemiyordu.)\n'
          '   - You/We/They + were not (weren\'t) + Ving\n'
          '     Örnek: "They weren\'t watching TV." (Televizyon izlemiyorlardı.)\n'
          '     Örnek: "You weren\'t working yesterday." (Dün çalışmıyordunuz.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Was + I/he/she/it + Ving...?\n'
          '     Örnek: "Was she crying?" (Ağlıyor muydu?)\n'
          '     Örnek: "Was it raining?" (Yağmur yağıyor muydu?)\n'
          '   - Were + you/we/they + Ving...?\n'
          '     Örnek: "Were you sleeping?" (Uyuyor muydun?)\n'
          '     Örnek: "Were they waiting for us?" (Bizi bekliyor muydular?)\n\n'
          '4. Past Continuous\'un kullanım amaçları:\n'
          '   - Geçmişte belirli bir zamanda devam eden bir eylem:\n'
          '     Örnek: "At 8 PM last night, I was reading a book." (Dün gece saat 8\'de kitap okuyordum.)\n'
          '   - Başka bir eylem gerçekleştiğinde devam eden bir eylem:\n'
          '     Örnek: "When she called, I was cooking dinner." (O aradığında, akşam yemeği pişiriyordum.)\n'
          '     Örnek: "The phone rang while I was taking a shower." (Ben duş alırken telefon çaldı.)\n'
          '   - Geçmişte aynı anda devam eden iki eylem:\n'
          '     Örnek: "While I was studying, my sister was watching TV." (Ben ders çalışırken, kız kardeşim televizyon izliyordu.)\n'
          '   - Geçmişteki uzun bir süre boyunca devam eden bir eylem:\n'
          '     Örnek: "It was raining all day yesterday." (Dün bütün gün yağmur yağıyordu.)\n'
          '   - Geçmişteki planlanmış ancak gerçekleşmemiş durumlar:\n'
          '     Örnek: "I was going to call you, but I forgot." (Seni arayacaktım ama unuttum.)\n\n'
          '5. Past Continuous ve Simple Past arasındaki fark:\n'
          '   - Simple Past: Geçmişte tamamlanmış, bitmiş eylemler için kullanılır.\n'
          '     Örnek: "I watched a movie yesterday." (Dün bir film izledim.)\n'
          '   - Past Continuous: Geçmişte devam eden, süreci vurgulanan eylemler için kullanılır.\n'
          '     Örnek: "I was watching a movie when she called." (O aradığında film izliyordum.)\n\n'
          '6. Past Continuous ile sıklıkla kullanılan bağlaçlar ve ifadeler:\n'
          '   - when (... -dığında): "When I arrived, they were having dinner." (Ben vardığımda, akşam yemeği yiyorlardı.)\n'
          '   - while (... -ken): "While I was working, it started to rain." (Çalışırken, yağmur yağmaya başladı.)\n'
          '   - at that time/moment (o zaman/anda): "At that moment, I was thinking about you." (O anda, seni düşünüyordum.)\n'
          '   - all day/night/morning (bütün gün/gece/sabah): "He was working all night." (Bütün gece çalışıyordu.)',
      subtopics: [],
    ),

    // PAST PERFECT (GEÇMİŞ ZAMAN ÖNCESİ)
    GrammarTopic(
      id: '6',
      title: 'Past Perfect (Geçmiş Zaman Öncesi)',
      description:
          'Geçmişteki başka bir olaydan önce gerçekleşen eylemler için kullanılır.',
      examples: [
        'I had already eaten when she arrived. (O geldiğinde ben çoktan yemek yemiştim.)',
        'They had lived in London before they moved to Paris. (Paris\'e taşınmadan önce Londra\'da yaşamışlardı.)',
        'Had you met him before the party? (Partiden önce onunla tanışmış mıydın?)',
        'She hadn\'t finished her homework when I called. (Ben aradığımda ödevini bitirmemişti.)',
      ],
      color: '#795548',
      iconPath: 'assets/icons/past_perfect.svg',
      grammar_structure:
          'Geçmiş zaman öncesi (Past Perfect), geçmişte başka bir eylemden önce tamamlanmış eylemleri ifade etmek için kullanılan bir zaman yapısıdır. Geçmişteki geçmiş zamanı belirtir.\n\n'
          '1. Olumlu cümleler:\n'
          '   - Tüm özneler (I/you/he/she/it/we/they) + had + past participle (V3)\n'
          '     Örnek: "I had finished my work before I went home." (Eve gitmeden önce işimi bitirmiştim.)\n'
          '     Örnek: "She had studied English before she moved to London." (Londra\'ya taşınmadan önce İngilizce çalışmıştı.)\n'
          '     Örnek: "They had lived in Paris for ten years before they moved to Rome." (Roma\'ya taşınmadan önce on yıl Paris\'te yaşamışlardı.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - Tüm özneler + had not (hadn\'t) + past participle\n'
          '     Örnek: "I hadn\'t seen that movie before last night." (Dün geceden önce o filmi görmemiştim.)\n'
          '     Örnek: "They hadn\'t finished their project when the deadline arrived." (Son tarih geldiğinde projelerini bitirmemişlerdi.)\n'
          '     Örnek: "She hadn\'t met his parents until the wedding." (Düğüne kadar onun ailesiyle tanışmamıştı.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Had + özne + past participle...?\n'
          '     Örnek: "Had you visited Paris before that trip?" (O geziden önce Paris\'i ziyaret etmiş miydin?)\n'
          '     Örnek: "Had she finished her homework when you called?" (Sen aradığında ödevini bitirmiş miydi?)\n'
          '     Örnek: "Had they ever seen snow before?" (Daha önce hiç kar görmüşler miydi?)\n\n'
          '4. Past Perfect\'in kullanım amaçları:\n'
          '   - Geçmişte bir eylemden önce tamamlanmış eylemler:\n'
          '     Örnek: "By the time I arrived, the meeting had started." (Ben vardığımda, toplantı başlamıştı.)\n'
          '   - Geçmişteki bir zamana kadar gerçekleşmiş deneyimler:\n'
          '     Örnek: "By 2010, I had already graduated from university." (2010 yılına kadar üniversiteden mezun olmuştum.)\n'
          '   - Unrealized past wishes or desires (if only/wish):\n'
          '     Örnek: "I wish I had studied harder." (Keşke daha çok çalışsaydım.)\n'
          '   - Reported speech (Dolaylı anlatım) için:\n'
          '     Örnek: "She said she had finished her homework." (Ödevini bitirdiğini söyledi.)\n\n'
          '5. Past Perfect ile sıklıkla kullanılan zaman ilişkileri ve bağlaçlar:\n'
          '   - before + simple past (... -den önce): "I had eaten before she arrived." (O gelmeden önce yemiştim.)\n'
          '   - after + past perfect (... -den sonra): "After I had finished my work, I went home." (İşimi bitirdikten sonra eve gittim.)\n'
          '   - by the time + simple past (... -e kadar): "By the time we arrived, they had left." (Biz vardığımızda, onlar gitmişlerdi.)\n'
          '   - when + simple past (... -dığında): "When I arrived, the movie had already started." (Ben vardığımda, film çoktan başlamıştı.)\n'
          '   - until + simple past (... -e kadar): "I hadn\'t realized how serious it was until the doctor explained." (Doktor açıklayana kadar ne kadar ciddi olduğunu anlamamıştım.)\n'
          '   - by + past time (... -e kadar): "By yesterday, they had completed the project." (Dün itibarıyla, projeyi tamamlamışlardı.)\n\n'
          '6. Past Perfect ve Simple Past arasındaki fark:\n'
          '   - Simple Past: Geçmişte belirli bir zamanda gerçekleşen eylemler.\n'
          '     Örnek: "I visited Rome last year." (Geçen yıl Roma\'yı ziyaret ettim.)\n'
          '   - Past Perfect: Geçmişteki başka bir olaydan önce gerçekleşen eylemler.\n'
          '     Örnek: "I had visited Rome before I went to Paris." (Paris\'e gitmeden önce Roma\'yı ziyaret etmiştim.)\n\n'
          '7. Zaman belirteçleri ile kullanımı:\n'
          '   - already (çoktan): "They had already left." (Çoktan gitmişlerdi.)\n'
          '   - just (henüz/az önce): "She had just finished cooking." (Yemek yapmayı henüz bitirmişti.)\n'
          '   - never (hiç): "I had never seen such a beautiful place." (Bu kadar güzel bir yer hiç görmemiştim.)\n'
          '   - for + time period (... süre boyunca): "They had lived there for 5 years." (5 yıl boyunca orada yaşamışlardı.)\n'
          '   - since + point in time (... -den beri): "He had worked there since 2005." (2005\'ten beri orada çalışmıştı.)',
      subtopics: [],
    ),

    // WILL FUTURE (GELECEK ZAMAN)
    GrammarTopic(
      id: '7',
      title: 'Will Future (Gelecek Zaman)',
      description:
          'Tahminler, sözler, teklifler ve anlık kararlar için kullanılır.',
      examples: [
        'I think it will rain tomorrow. (Yarın yağmur yağacağını düşünüyorum.)',
        'I will help you with your homework. (Ödevinde sana yardım edeceğim.)',
        'I\'ll take the blue one, please. (Mavi olanı alacağım, lütfen.)',
        'Will you marry me? (Benimle evlenir misin?)',
        'She won\'t come to the party. (O partiye gelmeyecek.)',
      ],
      color: '#FF5722',
      iconPath: 'assets/icons/will_future.svg',
      grammar_structure:
          'Will ile gelecek zaman, gelecekteki eylemleri tahmin etmek, anlık kararlar almak, söz vermek veya bir şey teklif etmek için kullanılan bir zaman yapısıdır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - Tüm özneler (I/you/he/she/it/we/they) + will + V1 (temel fiil)\n'
          '     Örnek: "I will help you tomorrow." (Yarın sana yardım edeceğim.)\n'
          '     Örnek: "She will finish the project on time." (Projeyi zamanında bitirecek.)\n'
          '   - Kısaltma: \'ll (I\'ll, you\'ll, she\'ll, vb.)\n'
          '     Örnek: "I\'ll call you later." (Seni daha sonra arayacağım.)\n'
          '     Örnek: "We\'ll be there by 8 PM." (Akşam 8\'e kadar orada olacağız.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - Tüm özneler + will not (won\'t) + V1\n'
          '     Örnek: "I won\'t forget your birthday." (Doğum gününü unutmayacağım.)\n'
          '     Örnek: "They won\'t arrive until tomorrow." (Yarına kadar varmayacaklar.)\n'
          '     Örnek: "She won\'t be happy about this." (Bundan memnun olmayacak.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Will + özne + V1...?\n'
          '     Örnek: "Will you attend the meeting?" (Toplantıya katılacak mısın?)\n'
          '     Örnek: "Will she recognize me?" (Beni tanıyacak mı?)\n'
          '     Örnek: "Will they accept our offer?" (Teklifimizi kabul edecekler mi?)\n\n'
          '4. "Will" kullanım amaçları:\n'
          '   - Gelecekle ilgili tahminler:\n'
          '     Örnek: "I think it will snow tomorrow." (Yarın kar yağacağını düşünüyorum.)\n'
          '     Örnek: "The economy will improve next year." (Ekonomi gelecek yıl düzelecek.)\n'
          '   - Anlık kararlar (konuşma anında verilen):\n'
          '     Örnek: "I\'ll help you with those bags." (O çantalarla sana yardım edeceğim.)\n'
          '     Örnek: "I\'ll take the blue one." (Mavi olanı alacağım.)\n'
          '   - Söz vermeler:\n'
          '     Örnek: "I will always love you." (Seni her zaman seveceğim.)\n'
          '     Örnek: "I promise I won\'t tell anyone." (Söz veriyorum kimseye söylemeyeceğim.)\n'
          '   - Teklifler:\n'
          '     Örnek: "I\'ll carry that for you." (Onu senin için taşıyacağım.)\n'
          '     Örnek: "I\'ll make dinner tonight." (Bu akşam yemeği ben yapacağım.)\n'
          '   - Ricalar:\n'
          '     Örnek: "Will you help me, please?" (Bana yardım eder misin, lütfen?)\n'
          '     Örnek: "Will you open the window?" (Pencereyi açar mısın?)\n'
          '   - Tehditler veya uyarılar:\n'
          '     Örnek: "You will regret this!" (Bundan pişman olacaksın!)\n'
          '     Örnek: "You\'ll miss the train if you don\'t hurry." (Acele etmezsen treni kaçıracaksın.)\n\n'
          '5. Sıklıkla kullanılan zaman belirteçleri:\n'
          '   - tomorrow (yarın), next week/month/year (gelecek hafta/ay/yıl)\n'
          '   - soon (yakında), in the future (gelecekte), later (daha sonra)\n'
          '   - tonight (bu gece), in + time period (bir zaman dilimi içinde): in two days (iki gün içinde)\n'
          '   - by + time (belirli bir zamana kadar): by Monday (Pazartesi\'ye kadar)',
      subtopics: [],
    ),

    // GOING TO FUTURE (PLANLANMIŞ GELECEK ZAMAN)
    GrammarTopic(
      id: '8',
      title: 'Going to Future (Planlanmış Gelecek Zaman)',
      description:
          'Önceden planlanmış eylemler ve gelecekteki olaylar hakkında güçlü tahminler için kullanılır.',
      examples: [
        'I am going to study medicine. (Tıp okuyacağım.)',
        'She is going to call him tonight. (Bu gece onu arayacak.)',
        'They are not going to attend the wedding. (Düğüne katılmayacaklar.)',
        'Are you going to visit your grandparents? (Büyükanne ve büyükbabanı ziyaret edecek misin?)',
        'Look at those clouds! It\'s going to rain. (Şu bulutlara bak! Yağmur yağacak.)',
      ],
      color: '#FF9800',
      iconPath: 'assets/icons/going_to_future.svg',
      grammar_structure:
          'Going to ile gelecek zaman, önceden planlanmış eylemleri veya belirgin işaretlere dayalı tahminleri ifade etmek için kullanılır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - Özne + am/is/are + going to + V1 (temel fiil)\n'
          '     Örnek: "I am going to study tonight." (Bu gece çalışacağım.)\n'
          '     Örnek: "She is going to paint the house." (Evi boyayacak.)\n'
          '     Örnek: "They are going to move to London." (Londra\'ya taşınacaklar.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - Özne + am/is/are + not + going to + V1\n'
          '     Örnek: "I am not going to watch that movie." (O filmi izlemeyeceğim.)\n'
          '     Örnek: "He is not going to buy a new car." (Yeni bir araba almayacak.)\n'
          '     Örnek: "We are not going to visit them." (Onları ziyaret etmeyeceğiz.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Am/Is/Are + özne + going to + V1...?\n'
          '     Örnek: "Are you going to apply for that job?" (O iş için başvuracak mısın?)\n'
          '     Örnek: "Is she going to attend the meeting?" (Toplantıya katılacak mı?)\n'
          '     Örnek: "Are they going to stay at a hotel?" (Bir otelde mi kalacaklar?)\n\n'
          '4. "Going to" kullanım amaçları:\n'
          '   - Önceden planlanmış eylemler:\n'
          '     Örnek: "I am going to study in Paris next year." (Gelecek yıl Paris\'te okuyacağım.)\n'
          '     Örnek: "We are going to build a new house." (Yeni bir ev inşa edeceğiz.)\n'
          '   - Güçlü tahminler (şu anki duruma dayalı):\n'
          '     Örnek: "Look at those clouds. It is going to rain." (Şu bulutlara bak. Yağmur yağacak.)\n'
          '     Örnek: "She is feeling sick. I think she is going to throw up." (Kendini hasta hissediyor. Sanırım kusacak.)\n'
          '   - Kaçınılmaz olaylar:\n'
          '     Örnek: "The baby is going to be born in June." (Bebek Haziran ayında doğacak.)\n'
          '     Örnek: "They are going to get married in December." (Aralık ayında evlenecekler.)\n\n'
          '5. "Going to" ve "will" arasındaki farklar:\n'
          '   - "Going to" genellikle önceden planlanmış veya karar verilmiş eylemler için kullanılır.\n'
          '   - "Will" genellikle anlık kararlar veya genel tahminler için kullanılır.\n'
          '   - "Going to" daha kesin bir niyet ifade eder.\n'
          '   - "Going to" şu anki delillere dayalı tahminler için tercih edilir.\n\n'
          '6. Sıklıkla kullanılan zaman belirteçleri:\n'
          '   - soon (yakında), in the near future (yakın gelecekte)\n'
          '   - tomorrow (yarın), next week/month/year (gelecek hafta/ay/yıl)\n'
          '   - in + time period (zaman dilimi): in two hours (iki saat içinde)',
      subtopics: [],
    ),

    // FUTURE CONTINUOUS (GELECEKTE DEVAM EDEN ZAMAN)
    GrammarTopic(
      id: '9',
      title: 'Future Continuous (Gelecekte Devam Eden Zaman)',
      description:
          'Gelecekte belirli bir zamanda devam edecek eylemler için kullanılır.',
      examples: [
        'This time tomorrow, I will be flying to Paris. (Yarın bu saatte Paris\'e uçuyor olacağım.)',
        'She will be waiting for you at the airport. (O, havaalanında seni bekliyor olacak.)',
        'Will you be using the car tonight? (Bu gece arabayı kullanıyor olacak mısın?)',
        'They won\'t be working next week. (Gelecek hafta çalışıyor olmayacaklar.)',
      ],
      color: '#FFC107',
      iconPath: 'assets/icons/future_continuous.svg',
      grammar_structure:
          'Gelecek sürekli zaman (Future Continuous), gelecekte belirli bir zamanda devam ediyor olacak eylemleri ifade etmek için kullanılır.\n\n'
          '1. Olumlu cümleler:\n'
          '   - Özne + will + be + V-ing\n'
          '     Örnek: "I will be working at 8 PM tonight." (Bu gece saat 8\'de çalışıyor olacağım.)\n'
          '     Örnek: "They will be traveling all day tomorrow." (Yarın bütün gün seyahat ediyor olacaklar.)\n'
          '     Örnek: "She will be studying when you call." (Sen aradığında çalışıyor olacak.)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - Özne + will + not + be + V-ing\n'
          '     Örnek: "I won\'t be sleeping at midnight." (Gece yarısı uyuyor olmayacağım.)\n'
          '     Örnek: "He won\'t be attending the meeting." (Toplantıya katılıyor olmayacak.)\n'
          '     Örnek: "They won\'t be using the office next week." (Gelecek hafta ofisi kullanıyor olmayacaklar.)\n\n'
          '3. Soru cümleleri:\n'
          '   - Will + özne + be + V-ing...?\n'
          '     Örnek: "Will you be watching TV at 8 o\'clock?" (Saat 8\'de televizyon izliyor olacak mısın?)\n'
          '     Örnek: "Will she be waiting for us?" (Bizi bekliyor olacak mı?)\n'
          '     Örnek: "Will they be using the computer?" (Bilgisayarı kullanıyor olacaklar mı?)\n\n'
          '4. Gelecek sürekli zamanın kullanım amaçları:\n'
          '   - Gelecekte belirli bir zamanda devam edecek eylemler:\n'
          '     Örnek: "This time next week, I will be sitting on a beach." (Gelecek hafta bu zamanda, bir plajda oturuyor olacağım.)\n'
          '     Örnek: "At 9 PM, she will be giving a presentation." (Saat 9\'da bir sunum yapıyor olacak.)\n'
          '   - Gelecekte planlanmış ve doğal olarak gerçekleşecek eylemler:\n'
          '     Örnek: "I will be visiting my parents anyway, so I can bring your package." (Zaten ailemi ziyaret ediyor olacağım, bu yüzden paketini getirebilirim.)\n'
          '     Örnek: "She will be passing your house on her way home." (Eve giderken senin evinizin önünden geçiyor olacak.)\n'
          '   - Kibarca sormak için kullanılan sorular:\n'
          '     Örnek: "Will you be using the car tomorrow?" (Yarın arabayı kullanıyor olacak mısın?) - bu soru "Can I use the car tomorrow?" (Yarın arabayı kullanabilir miyim?) sorusundan daha kibardır.\n'
          '     Örnek: "Will you be going to the supermarket later?" (Daha sonra markete gidiyor olacak mısın?) - bu soru "Can you buy something for me?" (Bana bir şey alabilir misin?) sorusundan daha kibardır.\n\n'
          '5. Future Continuous ve Future Simple arasındaki farklar:\n'
          '   - Future Continuous (will be + V-ing) gelecekte belirli bir zamanda devam eden bir eylemi vurgular.\n'
          '   - Future Simple (will + V1) gelecekte gerçekleşecek bir eylemi belirtir ancak devam etme vurgusu yoktur.\n\n'
          '6. Sıklıkla kullanılan zaman belirteçleri:\n'
          '   - at this time tomorrow/next week (yarın/gelecek hafta bu saatte)\n'
          '   - all day/week (bütün gün/hafta), during + zaman (during the summer - yaz boyunca)\n'
          '   - when + cümle (when you arrive - sen vardığında)',
      subtopics: [],
    ),

    // CAN/COULD (YAPABİLMEK)
    GrammarTopic(
      id: '10',
      title: 'Can/Could (Yapabilmek)',
      description: 'Yetenek, olasılık, izin veya rica için kullanılır.',
      examples: [
        'I can speak three languages. (Üç dil konuşabilirim.)',
        'It could rain later today. (Bugün daha sonra yağmur yağabilir.)',
        'Could you help me with this bag? (Bu çantayla bana yardım edebilir misin?)',
      ],
      color: '#E91E63',
      iconPath: 'assets/icons/modal_verbs.svg',
      grammar_structure:
          'Can ve Could modal fiilleri şu yapılarla kullanılır:\n\n'
          '1. Olumlu cümleler:\n'
          '   - Tüm özneler + can/could + V1 (temel fiil)\n\n'
          '2. Olumsuz cümleler:\n'
          '   - Tüm özneler + cannot (can\'t) / could not (couldn\'t) + V1\n\n'
          '3. Soru cümleleri:\n'
          '   - Can/Could + özne + V1...?\n\n'
          '4. Kullanım amaçları:\n'
          '   - Şimdiki yetenek: "I can swim. (Yüzebilirim.)" \n'
          '   - Geçmişteki yetenek: "When I was young, I could run fast. (Gençken hızlı koşabilirdim.)"\n'
          '   - İzin: "You can use my phone. (Telefonumu kullanabilirsin.)"\n'
          '   - Olasılık: "It can be difficult sometimes. (Bazen zor olabilir.)"\n'
          '   - Rica (could daha kibardır): "Could you open the window? (Pencereyi açabilir misiniz?)"\n'
          '   - Öneri: "We can go to the cinema. (Sinemaya gidebiliriz.)"\n\n'
          '5. Be able to:\n'
          '   - Can/could yerine kullanılabilir\n'
          '   - Tüm zamanlarda kullanılabilir: "I will be able to help you tomorrow. (Yarın sana yardım edebileceğim.)"',
      subtopics: [],
    ),

    // MUST/HAVE TO (ZORUNDA OLMAK)
    GrammarTopic(
      id: '11',
      title: 'Must/Have to (Zorunda Olmak)',
      description:
          'Zorunluluk, gereklilik veya güçlü olasılık için kullanılır.',
      examples: [
        'You must stop at a red light. (Kırmızı ışıkta durmalısın.)',
        'I have to finish this report by Friday. (Bu raporu Cuma gününe kadar bitirmek zorundayım.)',
        'She must be at home; her car is in the driveway. (Evde olmalı; arabası garaj yolunda.)',
      ],
      color: '#9C27B0',
      iconPath: 'assets/icons/modal_verbs.svg',
      grammar_structure:
          'Must ve Have to modal fiilleri şu yapılarla kullanılır:\n\n'
          '1. Olumlu cümleler:\n'
          '   - Tüm özneler + must + V1 (temel fiil)\n'
          '   - I/you/we/they + have to + V1\n'
          '   - He/she/it + has to + V1\n\n'
          '2. Olumsuz cümleler:\n'
          '   - Tüm özneler + must not (mustn\'t) + V1 (yasak)\n'
          '   - I/you/we/they + do not (don\'t) have to + V1 (gerek yok)\n'
          '   - He/she/it + does not (doesn\'t) have to + V1 (gerek yok)\n\n'
          '3. Soru cümleleri:\n'
          '   - Must + özne + V1...? (çok yaygın değil)\n'
          '   - Do + I/you/we/they + have to + V1...?\n'
          '   - Does + he/she/it + have to + V1...?\n\n'
          '4. Must ile Have to arasındaki farklar:\n'
          '   - Must: Kişisel zorunluluk, konuşmacının kararı veya inancı\n'
          '   - Have to: Dışarıdan gelen zorunluluk, kurallar, şartlar\n'
          '   - Must not: Bir şey yapmanın yasak olması (Don\'t do it!)\n'
          '   - Don\'t have to: Bir şeyi yapmanın gerekli olmaması (It\'s optional)\n\n'
          '5. Must\'ın diğer kullanımları:\n'
          '   - Güçlü olasılık: "She must be tired." (Yorgun olmalı.)\n'
          '   - Güçlü tavsiye: "You must see this film!" (Bu filmi kesinlikle görmelisin!)',
      subtopics: [],
    ),

    // SHOULD/OUGHT TO (YAPMALI)
    GrammarTopic(
      id: '12',
      title: 'Should/Ought to (Yapmalı)',
      description: 'Tavsiye, öneri veya beklenti için kullanılır.',
      examples: [
        'You should exercise regularly. (Düzenli egzersiz yapmalısın.)',
        'I think we ought to leave early to avoid traffic. (Trafiğe yakalanmamak için erken çıkmalıyız diye düşünüyorum.)',
        'The package should arrive tomorrow. (Paket yarın gelmelidir.)',
      ],
      color: '#673AB7',
      iconPath: 'assets/icons/modal_verbs.svg',
      grammar_structure: 'Yapı: Özne + should/ought to + temel fiil\n'
          'Must\'tan daha az güçlüdür; tavsiye edileni ifade eder.\n'
          'Olasılık veya beklenti ifade etmek için kullanılabilir.\n'
          'Should have done yapısı geçmişteki pişmanlıklar için kullanılır.',
      subtopics: [],
    ),

    // ZERO CONDITIONAL (SIFIR KOŞUL)
    GrammarTopic(
      id: '13',
      title: 'Zero Conditional (Sıfır Koşul)',
      description: 'Genel gerçekler veya bilimsel gerçekler için kullanılır.',
      examples: [
        'If you heat water to 100°C, it boils. (Suyu 100°C\'ye ısıtırsanız, kaynar.)',
        'If it rains, the ground gets wet. (Yağmur yağarsa, zemin ıslanır.)',
        'If you don\'t eat, you get hungry. (Yemezsen, acıkırsın.)',
      ],
      color: '#FF5722',
      iconPath: 'assets/icons/conditionals.svg',
      grammar_structure: 'Yapı: If + geniş zaman, geniş zaman\n'
          'If yerine when kullanılabilir.\n'
          'Koşul yerine getirildiğinde sonuç her zaman gerçekleşir.\n'
          'Bilimsel gerçekler ve değişmez kurallar için kullanılır.',
      subtopics: [],
    ),

    // FIRST CONDITIONAL (BİRİNCİ KOŞUL)
    GrammarTopic(
      id: '14',
      title: 'First Conditional (Birinci Koşul)',
      description:
          'Gelecekte gerçekleşmesi mümkün olan koşullar için kullanılır.',
      examples: [
        'If it rains tomorrow, we will stay at home. (Yarın yağmur yağarsa, evde kalacağız.)',
        'If you study hard, you will pass the exam. (Sıkı çalışırsan, sınavı geçeceksin.)',
        'I won\'t go to the party if you don\'t come with me. (Benimle gelmezsen, partiye gitmeyeceğim.)',
      ],
      color: '#FF9800',
      iconPath: 'assets/icons/conditionals.svg',
      grammar_structure: 'Yapı: If + geniş zaman, will + temel fiil\n'
          'Gelecekte gerçekleşmesi olası durumlar için kullanılır\n'
          'Koşul cümlesi (if clause) geniş zamanda, sonuç cümlesi (main clause) gelecek zamanda\n'
          'Unless (eğer ... -mezse) ile de oluşturulabilir',
      subtopics: [],
    ),

    // SECOND CONDITIONAL (İKİNCİ KOŞUL)
    GrammarTopic(
      id: '15',
      title: 'Second Conditional (İkinci Koşul)',
      description:
          'Şu anda veya gelecekte gerçekleşmesi pek olası olmayan koşullar için kullanılır.',
      examples: [
        'If I had a lot of money, I would travel the world. (Çok param olsaydı, dünyayı gezerdim.)',
        'She would call you if she knew your number. (Numaranı bilseydi, seni arardı.)',
        'What would you do if you won the lottery? (Piyango çıksa ne yapardın?)',
      ],
      color: '#FFC107',
      iconPath: 'assets/icons/conditionals.svg',
      grammar_structure: 'Yapı: If + geçmiş zaman, would + temel fiil\n'
          'Şu anda veya gelecekte gerçekleşmesi olası olmayan varsayımsal durumlar için kullanılır\n'
          'Was yerine were kullanılması daha yaygındır (If I were you...)\n'
          'Could ve might modal fiilleri de would yerine kullanılabilir',
      subtopics: [],
    ),

    // THIRD CONDITIONAL (ÜÇÜNCÜ KOŞUL)
    GrammarTopic(
      id: '16',
      title: 'Third Conditional (Üçüncü Koşul)',
      description:
          'Geçmişte gerçekleşmemiş koşullar ve sonuçları için kullanılır.',
      examples: [
        'If you had told me, I would have helped you. (Bana söyleseydin, sana yardım ederdim.)',
        'She would have passed the exam if she had studied harder. (Daha sıkı çalışsaydı, sınavı geçerdi.)',
        'I wouldn\'t have been late if I had taken a taxi. (Taksi tutmuş olsaydım, geç kalmazdım.)',
      ],
      color: '#FF5722',
      iconPath: 'assets/icons/conditionals.svg',
      grammar_structure:
          'Yapı: If + past perfect, would have + past participle\n'
          'Geçmişte gerçekleşmemiş koşulları ve bunların sonuçlarını ifade eder\n'
          'Gerçekleşmeyen durumların geçmişteki varsayımsal sonuçlarını gösterir\n'
          'Pişmanlık ifadelerinde sıkça kullanılır',
      subtopics: [],
    ),

    // PASSIVE VOICE (EDİLGEN YAPI)
    GrammarTopic(
      id: '17',
      title: 'Passive Voice (Edilgen Yapı)',
      description:
          'Eylemi yapandan çok, eylemin kendisine vurgu yapmak için kullanılır.',
      examples: [
        'The house was built in 1890. (Ev 1890\'da inşa edildi.)',
        'English is spoken in many countries. (İngilizce birçok ülkede konuşulur.)',
        'The letter will be delivered tomorrow. (Mektup yarın teslim edilecek.)',
        'My bike has been stolen! (Bisikletim çalınmış!)',
      ],
      color: '#3F51B5',
      iconPath: 'assets/icons/passive_voice.svg',
      grammar_structure:
          'Yapı: Özne + be fiili (am/is/are/was/were) + past participle (V3)\n'
          'Eylemi yapan yerine, eylemin kendisine veya etkilenene odaklanır\n'
          'Eylemi yapan belirtilmek istenirse "by" ile eklenir\n'
          'Tüm zamanlarda kullanılabilir (Present, Past, Future, Perfect vb.)',
      subtopics: [],
    ),

    // REPORTED SPEECH (AKTARILAN KONUŞMA)
    GrammarTopic(
      id: '18',
      title: 'Reported Speech (Dolaylı Anlatım)',
      description:
          'Başkalarının sözlerini veya düşüncelerini aktarmak için kullanılır.',
      examples: [
        'She said (that) she was tired. (Yorgun olduğunu söyledi.)',
        'He told me (that) he would call later. (Daha sonra arayacağını söyledi.)',
        'They asked if we were coming to the party. (Partiye gelip gelmeyeceğimizi sordular.)',
      ],
      color: '#9C27B0',
      iconPath: 'assets/icons/reported_speech.svg',
      grammar_structure:
          'Direkt konuşmayı aktarırken zamanları geriye kaydırma (backshift) yapılır\n'
          'Şahıs ve işaret zamirleri değişir (I → he/she, this → that vb.)\n'
          'Zaman ve yer belirteçleri değişir (now → then, today → that day vb.)\n'
          'Say, tell, ask gibi aktarma fiilleri kullanılır',
      subtopics: [],
    ),

    // GERUNDS AND INFINITIVES (MASTARLAR VE İSİM-FİİLLER)
    GrammarTopic(
      id: '19',
      title: 'Gerunds and Infinitives (Mastarlar ve İsim-Fiiller)',
      description:
          'Fiillerin -ing formunda (gerund) ve to ile (infinitive) kullanımı.',
      examples: [
        'I enjoy swimming. (Yüzmeyi severim.) - Gerund',
        'She wants to learn French. (Fransızca öğrenmek istiyor.) - Infinitive',
        'I stopped smoking. (Sigara içmeyi bıraktım.) - Gerund',
        'They decided to buy a new car. (Yeni bir araba almaya karar verdiler.) - Infinitive',
      ],
      color: '#4CAF50',
      iconPath: 'assets/icons/gerunds_infinitives.svg',
      grammar_structure:
          'Bazı fiiller sadece gerund alır: enjoy, finish, mind, consider\n'
          'Bazı fiiller sadece infinitive alır: want, hope, decide, plan\n'
          'Bazı fiiller hem gerund hem infinitive alabilir: like, love, hate, begin\n'
          'Anlamı değişen fiiller: remember to do (yapmayı hatırlamak) / remember doing (yaptığını hatırlamak)',
      subtopics: [],
    ),

    // ARTICLES (ARTIKELLER: A, AN, THE)
    GrammarTopic(
      id: '20',
      title: 'Articles (Artikeller: A, An, The)',
      description: 'İsimleri tanımlamaya ve belirtmeye yarayan kelimeler.',
      examples: [
        'I saw a cat in the garden. (Bahçede bir kedi gördüm.)',
        'She is an engineer. (O bir mühendistir.)',
        'The sun rises in the east. (Güneş doğudan doğar.)',
        'I need some water. (Biraz su ihtiyacım var.)',
      ],
      color: '#00BCD4',
      iconPath: 'assets/icons/articles.svg',
      grammar_structure:
          'A/An belirsiz artikeldir ve tekil sayılabilir isimlerle kullanılır\n'
          'The belirli artikeldir ve konuşmacı ve dinleyicinin bildiği şeyler için kullanılır\n'
          'A ünsüz sesle başlayan kelimelerle, an ünlü sesle başlayan kelimelerle kullanılır\n'
          'Bazı durumlarda hiç artikel kullanılmaz (genel ifadeler, soyut isimler, çoğul isimler)',
      subtopics: [],
    ),
  ];
}
