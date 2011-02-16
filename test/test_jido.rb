# coding: utf-8

require 'helper'

class TestJido < Test::Unit::TestCase
  should "prepare verb forms" do
    jido = Jido.load 'fr'
    assert_not_nil jido
    
    assert_equal 'fr', jido.lang
    assert_equal ['prs', 'pcomp', 'imp', 'plu', 'futsimp', 'futant', 'passimp', 'pstant', 'subprs', 'subpst', 'subimp', 'subplu', 'cprs', 'cpst', 'cpst2', 'impprs', 'imppst'], jido.forms
  end

  should "conjugate some verbs correctly" do
    jido = Jido.load 'fr'
    assert_not_nil jido
    
    conj1 = jido.conjugate 'être'
    assert_equal conj1, {
    #p jido.conjugate('être').diff({
      'prs' => { # present
        '1sg' => 'suis',          '1pl' => 'sommes',
        '2sg' => 'es',            '2pl' => 'êtes',
        '3sg' => 'est',           '3pl' => 'sont'
      },
      'pcomp' => { # passé composé
        '1sg' => 'ai été',        '1pl' => 'avons été',
        '2sg' => 'as été',        '2pl' => 'avez été',
        '3sg' => 'a été',         '3pl' => 'ont été'
      },
      'imp' => { # imperfect
        '1sg' => 'étais',         '1pl' => 'étions',
        '2sg' => 'étais',         '2pl' => 'étiez',
        '3sg' => 'était',         '3pl' => 'étaient'
      },
      'plu' => { # pluperfect
        '1sg' => 'avais été',     '1pl' => 'avions été',
        '2sg' => 'avais été',     '2pl' => 'aviez été',
        '3sg' => 'avait été',     '3pl' => 'avaient été'
      },
      'futsimp' => { # future
        '1sg' => 'serai',         '1pl' => 'serons',
        '2sg' => 'seras',         '2pl' => 'serez',
        '3sg' => 'sera',          '3pl' => 'seront'
      },
      'futant' => { # future perfect
        '1sg' => 'aurai été',     '1pl' => 'aurons été',
        '2sg' => 'auras été',     '2pl' => 'aurez été',
        '3sg' => 'aura été',      '3pl' => 'auront été'
      },
      'passimp' => { # simple past
        '1sg' => 'fus',           '1pl' => 'fûmes',
        '2sg' => 'fus',           '2pl' => 'fûtes',
        '3sg' => 'fut',           '3pl' => 'furent'
      },
      'pstant' => { # past anterior
        '1sg' => 'eus été',       '1pl' => 'eûmes été',
        '2sg' => 'eus été',       '2pl' => 'eûtes été',
        '3sg' => 'eut été',       '3pl' => 'eurent été'
      },
      'subprs' => { # subjunctive present
        '1sg' => 'sois',          '1pl' => 'soyons',
        '2sg' => 'sois',          '2pl' => 'soyez',
        '3sg' => 'soit',          '3pl' => 'soient'
      },
      'subpst' => { # subjunctive past
        '1sg' => 'aie été',       '1pl' => 'ayons été',
        '2sg' => 'aies été',      '2pl' => 'ayez été',
        '3sg' => 'ait été',       '3pl' => 'aient été'
      },
      'subimp' => { # subjunctive imperfect
        '1sg' => 'fusse',         '1pl' => 'fussions',
        '2sg' => 'fusses',        '2pl' => 'fussiez',
        '3sg' => 'fût',           '3pl' => 'fussent'
      },
      'subplu' => { # subjunctive pluperfect
        '1sg' => 'eusse été',     '1pl' => 'eussions été',
        '2sg' => 'eusses été',    '2pl' => 'eussiez été',
        '3sg' => 'eût été',       '3pl' => 'eussent été'
      },
      'cprs' => { # conditional present
        '1sg' => 'serais',        '1pl' => 'serions',
        '2sg' => 'serais',        '2pl' => 'seriez',
        '3sg' => 'serait',        '3pl' => 'seraient'
      },
      'cpst' => { # conditional past
        '1sg' => 'aurais été',    '1pl' => 'aurions été',
        '2sg' => 'aurais été',    '2pl' => 'auriez été',
        '3sg' => 'aurait été',    '3pl' => 'auraient été'
      },
      'cpst2' => { # conditional past II
        '1sg' => 'eusse été',     '1pl' => 'eussions été',
        '2sg' => 'eusses été',    '2pl' => 'eussiez été',
        '3sg' => 'eût été',       '3pl' => 'eussent été'
      },
      'impprs' => { # imperative present
                                  '1pl' => 'soyons !',
        '2sg' => 'sois !',        '2pl' => 'soyez !'
      },
      'imppst' => { # imperative past
                                  '1pl' => 'ayons été',
        '2sg' => 'aie été',       '2pl' => 'ayez été'
      }
    }
  end
end
