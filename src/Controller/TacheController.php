<?php

namespace App\Controller;

use App\Entity\Tache;
use App\Form\TacheType;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class TacheController extends AbstractController
{
    #[Route('/', name: 'home')]
    public function index(
        Request $request,
        EntityManagerInterface $em
    ): Response {

        $tache = new Tache();
        $form = $this->createForm(TacheType::class, $tache);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $em->persist($tache);
            $em->flush();

            return $this->redirectToRoute('home');
        }

        $taches = $em->getRepository(Tache::class)->findAll();

        return $this->render('tache/index.html.twig', [
            'taches' => $taches,
            'form' => $form->createView(),
        ]);
    }

    #[Route('/delete/{id}', name: 'delete')]
    public function delete(Tache $tache, EntityManagerInterface $em)
    {
        $em->remove($tache);
        $em->flush();

        return $this->redirectToRoute('home');
    }
}