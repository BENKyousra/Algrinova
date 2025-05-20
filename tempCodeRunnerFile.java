import java.util.*;

class Etudiant {
    String nom;
    int niveau; // 1 pour L1, 2 pour L2, 3 pour L3, 4 pour Master1, 5 pour Master2

    public Etudiant(String nom, int niveau) {
        this.nom = nom;
        this.niveau = niveau;
    }

    public String toString() {
        return nom + " (Niveau " + niveau + ")";
    }
}


public class tempCodeRunnerFile {
    public static void main(String[] args) {
        // Étape 1 : Création du comparator
        Comparator<Etudiant> comp = new Comparator<Etudiant>() {
            public int compare(Etudiant e1, Etudiant e2) {
                return Integer.compare(e2.niveau, e1.niveau); // tri décroissant
            }
        };

        // Étape 2 : Création de la PriorityQueue
        PriorityQueue<Etudiant> file = new PriorityQueue<>(comp);

        // Étape 3 : Ajout d’étudiants
        file.add(new Etudiant("Ali", 1));
        file.add(new Etudiant("Leila", 3));
        file.add(new Etudiant("Nora", 5));
        file.add(new Etudiant("Sami", 4));

        // Étape 4 : Affichage
        while (!file.isEmpty()) {
            System.out.println(file.poll());
        }
    }
}
