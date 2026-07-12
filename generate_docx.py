import docx

doc = docx.Document()

doc.add_heading('Analisis Penuh Alur Cerita dan Kerangka Kerja Visual Novel "Jika Kucing Lenyap Dari Dunia"', 0)

doc.add_paragraph('Dokumen ini berisi analisis lengkap dari struktur game visual novel mulai dari main menu hingga bagian akhir (credit scene), mencakup alur cerita, script, dialog, dan scene yang digunakan di setiap tahapnya.')

# 1. Main Menu & UI
doc.add_heading('1. Main Menu & UI', level=1)
doc.add_paragraph('Bagian awal ketika pemain membuka game dan antarmuka UI pendukung (HUD/Transisi).')
p1 = doc.add_paragraph()
p1.add_run('Scene: ').bold = True
p1.add_run('main_menu.tscn, ObjectiveHUD.tscn, ScreenFade.tscn')
p2 = doc.add_paragraph()
p2.add_run('Script: ').bold = True
p2.add_run('main_menu.gd, objective_hud.gd, screen_fade.gd, portrait_dimmer.gd, portrait_toggler.gd')
p3 = doc.add_paragraph()
p3.add_run('Alur: ').bold = True
p3.add_run('Pemain memulai permainan dari Main Menu. Terdapat sistem transisi layar dan HUD objektif untuk membimbing pemain sepanjang game.')

# 2. Prolog
doc.add_heading('2. Prolog', level=1)
doc.add_paragraph('Tahap pengenalan cerita saat MC pertama kali mendapat vonis.')
p4 = doc.add_paragraph()
p4.add_run('Scene: ').bold = True
p4.add_run('prolog.tscn')
p5 = doc.add_paragraph()
p5.add_run('Dialog: ').bold = True
p5.add_run('prolog_vonis.dtl')
p6 = doc.add_paragraph()
p6.add_run('Script: ').bold = True
p6.add_run('prolog.gd, story_manager.gd')
p7 = doc.add_paragraph()
p7.add_run('Alur Cerita: ').bold = True
p7.add_run('MC mengunjungi dokter dan divonis memiliki penyakit mematikan yang membuatnya berumur pendek. Di sini mulai dikenalkan konsep kematian. Setelah adegan prologue selesai, scene berpindah ke kamar MC.')

# 3. Hari ke-0: Pertemuan dengan Iblis
doc.add_heading('3. Hari ke-0: Pertemuan dengan Iblis', level=1)
doc.add_paragraph('Awal mula permainan di mana tawaran sang Iblis terjadi.')
p8 = doc.add_paragraph()
p8.add_run('Scene: ').bold = True
p8.add_run('kamar_mc.tscn, flashback.tscn')
p9 = doc.add_paragraph()
p9.add_run('Dialog: ').bold = True
p9.add_run('hari0_bangun.dtl, hari0_flashback.dtl, hari0_malam_aloha.dtl, tidur_malam.dtl')
p10 = doc.add_paragraph()
p10.add_run('Script: ').bold = True
p10.add_run('kamar_mc_root.gd, interactable.gd, story_manager.gd, player.gd')
p11 = doc.add_paragraph()
p11.add_run('Alur Cerita: ').bold = True
p11.add_run('MC terbangun di kamarnya dalam keadaan pusing. Ia kemudian mendapatkan telepon yang memicu kilas balik (flashback). Pada malam harinya, sang iblis bernama Aloha datang menampakkan diri. Aloha memberikan tawaran untuk memperpanjang hidup MC selama satu hari dengan syarat melenyapkan satu benda di dunia, dengan benda pertama adalah "Telepon". MC setuju dan tidur.')

# 4. Hari ke-1: Lenyapnya Telepon dan Bertemu Mantan
doc.add_heading('4. Hari ke-1: Lenyapnya Telepon dan Bertemu Mantan', level=1)
doc.add_paragraph('Benda pertama (telepon) telah lenyap dari dunia.')
p12 = doc.add_paragraph()
p12.add_run('Scene: ').bold = True
p12.add_run('kamar_mc.tscn, jalanan_kota.tscn, cafe.tscn, jalan_malam_cutscene.tscn, bioskop.tscn')
p13 = doc.add_paragraph()
p13.add_run('Dialog: ').bold = True
p13.add_run('hari1_pagi_kamar.dtl, hari1_cermin.dtl, hari1_dapur.dtl, hari1_pintu.dtl, hari1_siang_cafe.dtl, hari1_taman.dtl, hari1_mantan_datang.dtl, hari1_malam_jalan.dtl, hari1_malam_bioskop.dtl')
p14 = doc.add_paragraph()
p14.add_run('Script: ').bold = True
p14.add_run('cafe_chair_trigger.gd, cutscene_jalan.gd, jalanan_kota_root.gd, story_trigger.gd, story_manager.gd')
p15 = doc.add_paragraph()
p15.add_run('Alur Cerita: ').bold = True
p15.add_run('Pagi hari MC mendapati telepon sudah tidak ada. Ia memutuskan keluar kamar, mengecek cermin, dapur, lalu menuju Cafe di Jalanan Kota untuk menemui mantan pacarnya. Di siang hari terjadi dialog panjang dengan mantannya di cafe. Malam harinya saat MC di kamar, Mantan tiba-tiba datang untuk meminjam DVD. Mereka kemudian berjalan bersama di malam hari hingga sampai ke depan Bioskop. Setelah berpisah, MC pulang ke kamar dan tidur.')

# 5. Hari ke-2: Lenyapnya Film dan Kenangan Bioskop
doc.add_heading('5. Hari ke-2: Lenyapnya Film dan Kenangan Bioskop', level=1)
doc.add_paragraph('Aloha melenyapkan Film sebagai syarat kehidupan di hari kedua.')
p16 = doc.add_paragraph()
p16.add_run('Scene: ').bold = True
p16.add_run('kamar_mc.tscn, toko_dvd.tscn, bioskop.tscn, dalam_bioskop.tscn')
p17 = doc.add_paragraph()
p17.add_run('Dialog: ').bold = True
p17.add_run('hari2_bangun.dtl, hari2_siang_tsutaya.dtl, hari2_malam_bioskop.dtl')
p18 = doc.add_paragraph()
p18.add_run('Script: ').bold = True
p18.add_run('toko_dvd_cutscene.gd, bioskop_cutscene.gd, story_manager.gd')
p19 = doc.add_paragraph()
p19.add_run('Alur Cerita: ').bold = True
p19.add_run('Film (Bioskop dan DVD) menjadi target selanjutnya. MC bangun dan pergi ke toko DVD Tsutaya di siang hari untuk bertemu mantannya kembali demi membicarakan kenangan mereka. Malam harinya, MC mengenang momen-momen saat mereka menonton di dalam bioskop. Setelah itu MC kembali ke kamarnya untuk tidur.')

# 6. Hari ke-3: Lenyapnya Jam dan Pertimbangan Terakhir
doc.add_heading('6. Hari ke-3: Lenyapnya Jam dan Pertimbangan Terakhir', level=1)
doc.add_paragraph('Benda berikutnya adalah Jam, MC mulai tersadar dampak besar penghapusan barang-barang tersebut.')
p20 = doc.add_paragraph()
p20.add_run('Scene: ').bold = True
p20.add_run('kamar_mc.tscn, Taman_Bukit.tscn')
p21 = doc.add_paragraph()
p21.add_run('Dialog: ').bold = True
p21.add_run('hari3_pagi_kamar.dtl, hari3_taman_bagian1.dtl, hari3_taman_bagian2.dtl, hari3_malam_flashback.dtl, hari3_malam_kamar.dtl')
p22 = doc.add_paragraph()
p22.add_run('Script: ').bold = True
p22.add_run('taman_cutscene_hari3.gd, story_manager.gd, scene_transition.gd')
p23 = doc.add_paragraph()
p23.add_run('Alur Cerita: ').bold = True
p23.add_run('Jam (waktu) kini dilenyapkan. MC terbangun dengan kebingungan terkait konsep waktu. Ia memutuskan untuk pergi merenung di Taman Bukit dan memikirkan tindakan yang telah diambilnya. Pada malam hari di kamarnya, ia mengalami flashback kembali tentang hubungannya dan ibunya. Puncaknya, Aloha memberikan pilihan terakhir yang sangat berat: Jika MC ingin memperpanjang hidup lagi, ia harus melenyapkan "Kucing" (Kubis). Pilihan ini menjadi percabangan ke berbagai ending.')

# 7. Percabangan Ending (Hari ke-4 / Hari Tambahan)
doc.add_heading('7. Percabangan Ending (Hari ke-4 / Hari Alternatif)', level=1)
doc.add_paragraph('Pilihan pemain pada malam ke-3 menentukan cabang akhir cerita.')

# 7A. True Ending
doc.add_heading('A. True Ending (Menerima Takdir)', level=2)
p24 = doc.add_paragraph()
p24.add_run('Scene: ').bold = True
p24.add_run('kamar_mc.tscn')
p25 = doc.add_paragraph()
p25.add_run('Dialog: ').bold = True
p25.add_run('hari4_true_ending.dtl, true_ending.dtl')
p26 = doc.add_paragraph()
p26.add_run('Alur Cerita: ').bold = True
p26.add_run('MC menolak tawaran Aloha untuk melenyapkan Kucingnya (Kubis). Ia lebih memilih untuk mati daripada menghapus keberadaan hal yang sangat berharga. Aloha mengerti, lalu MC menghabiskan sisa waktunya membereskan kamar dan merawat kubis, menunggu kematiannya dengan hati tenang.')

# 7B. Ending Damai
doc.add_heading('B. Alternate Ending 1 (Ending Damai)', level=2)
p27 = doc.add_paragraph()
p27.add_run('Scene: ').bold = True
p27.add_run('kamar_mc.tscn, jalanan_kota.tscn, Taman_Bukit.tscn')
p28 = doc.add_paragraph()
p28.add_run('Dialog: ').bold = True
p28.add_run('alt_malam_terakhir.dtl, alt_pagi_terakhir.dtl, alt_mengantar_surat.dtl, alt_taman_bukit.dtl, alt_sore_kamar.dtl')
p29 = doc.add_paragraph()
p29.add_run('Alur Cerita: ').bold = True
p29.add_run('Cabang ini memungkinkan MC menulis surat terakhir untuk mantannya. MC berjalan ke jalanan kota untuk mengantar suratnya lalu merenung di Taman Bukit. Sore harinya, ia kembali ke kamar dan tertidur untuk selamanya dengan penuh kedamaian.')

# 7C. Ending Bangkit
doc.add_heading('C. Alternate Ending 2 (Ending Bangkit)', level=2)
p30 = doc.add_paragraph()
p30.add_run('Scene: ').bold = True
p30.add_run('kamar_mc.tscn, toko_dvd.tscn, jalan_malam_cutscene.tscn, dalam_bioskop.tscn')
p31 = doc.add_paragraph()
p31.add_run('Dialog: ').bold = True
p31.add_run('alt2_pagi_kamar.dtl, alt2_tsutaya.dtl, alt2_masuk_bioskop.dtl, alt2_luar_bioskop.dtl, alt2_dalam_bioskop.dtl, alt2_epilog.dtl, alt2_epilog_kamar.dtl')
p32 = doc.add_paragraph()
p32.add_run('Alur Cerita: ').bold = True
p32.add_run('MC memilih untuk tidak menyerah dan tidak membiarkan semuanya lenyap. Ia bangkit, mengunjungi toko DVD, lalu mengenang film bersama mantannya di bioskop. Epilog menunjukkan MC berdamai dengan masa lalunya namun memiliki tekad baru untuk menghabiskan sisa harinya tanpa mengorbankan apapun lagi.')

# 7D. Ending Kesepian
doc.add_heading('D. Ending C (Ending Kesepian)', level=2)
p33 = doc.add_paragraph()
p33.add_run('Scene: ').bold = True
p33.add_run('kamar_mc.tscn, jalan_malam_cutscene.tscn, dalam_bioskop.tscn')
p34 = doc.add_paragraph()
p34.add_run('Dialog: ').bold = True
p34.add_run('ending_c_kamar_awal.dtl, ending_c_ke_bioskop.dtl, ending_c_dalam_bioskop.dtl, ending_c_keluar_bioskop.dtl, ending_c_epilog.dtl, ending_c_pagi_bangun.dtl, ending_c_pagi_dapur.dtl, ending_c_jalanan.dtl')
p35 = doc.add_paragraph()
p35.add_run('Alur Cerita: ').bold = True
p35.add_run('Demi hidup abadi, MC terus menerima tawaran Aloha untuk melenyapkan benda, termasuk kucingnya. Pada akhirnya, MC berhasil bertahan hidup, namun ia sepenuhnya sendirian dan kehilangan semua kenangannya yang berharga. Kehidupan abadi tanpa koneksi emosional terasa sangat hampa dan menyiksa.')

# 8. Credit Scene
doc.add_heading('8. Credit Scene (Akhir Game)', level=1)
doc.add_paragraph('Penutup dari permainan menampilkan rol nama pembuat (credits).')
p36 = doc.add_paragraph()
p36.add_run('Scene: ').bold = True
p36.add_run('credit_scene.tscn, credit_damai.tscn, credit_bangkit.tscn, credit_kesepian.tscn')
p37 = doc.add_paragraph()
p37.add_run('Script: ').bold = True
p37.add_run('credit_scene.gd, credit_damai.gd, credit_bangkit.gd, credit_kesepian.gd')
p38 = doc.add_paragraph()
p38.add_run('Alur: ').bold = True
p38.add_run('Setelah cerita mencapai akhir, scene akan transisi layar hitam menuju salah satu dari credit scene sesuai dengan ending yang diraih. Teks berjalan perlahan dari bawah ke atas menampilkan seluruh tim yang terlibat (Programmer, Writer, Artist).')

doc.save('Analisis_Visual_Novel_Kucing_Lenyap.docx')
print("File DOCX telah berhasil dibuat.")
