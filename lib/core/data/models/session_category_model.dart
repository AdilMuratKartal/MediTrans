enum SessionCategory {
  breathwork('Nefes Egzersizi', 'NEFESE DEVAM ET', 'Nefese Devam Et'),
  yogaPose('Beden & Yoga', 'EGZERSİZE DEVAM ET', 'Egzersize Devam Et'),
  frequency('Hz Frekansı', 'FREKANSA DEVAM ET', 'Frekansa Devam Et'),
  natureSound('Doğa Sesi', 'DOĞA SESİNE DEVAM ET', 'Doğa Sesine Devam Et'),
  noiseSound('Gürültü Frekansı', 'GÜRÜLTÜ SESİNE DEVAM ET', 'Gürültü Sesine Devam Et'),
  sleepStory('Uyku Hikayesi', 'HİKAYEYE DEVAM ET', 'Hikayeye Devam Et');

  final String labelTr;
  final String continueHeaderLabelTr;
  final String continueActionLabelTr;
  const SessionCategory(this.labelTr, this.continueHeaderLabelTr, this.continueActionLabelTr);
}

